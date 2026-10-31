"""Fake release command boundaries; never contacts GitHub or mutates the real repository."""

import json
import os
from pathlib import Path
import subprocess
import sys

configuration = json.loads(os.environ["RELEASE_TEST_CASE"])
command = Path(sys.argv[0]).name
arguments = sys.argv[1:]
with Path(os.environ["RELEASE_TEST_CALLS"]).open("a") as stream:
    stream.write(json.dumps([command, *arguments]) + "\n")
if command == "git":
    if arguments == ["rev-parse", "--abbrev-ref", "HEAD"]:
        print(configuration.get("branch", "main"))
    elif arguments == ["status", "--porcelain"]:
        print(" M changed.py" if configuration.get("dirty") else "", end="")
    elif arguments[:1] == ["fetch"]:
        sys.exit(configuration.get("fetch_status", 0))
    elif arguments == ["rev-parse", "HEAD"]:
        print(configuration.get("head", "tested"))
    elif arguments[:1] == ["rev-parse"] and arguments[-1].startswith("origin/"):
        print(configuration.get("origin", configuration.get("head", "tested")))
    elif arguments == ["rev-parse", "HEAD^"]:
        print(configuration.get("parent", "parent"))
    elif arguments == ["rev-parse", "-q", "--verify", "HEAD^2"]:
        sys.exit(0 if configuration.get("merge") else 1)
    elif arguments[:3] == ["rev-parse", "-q", "--verify"]:
        version = arguments[-1].removeprefix("refs/tags/v").removesuffix("^{commit}")
        commit = configuration.get("tags", {}).get(version)
        if commit is None:
            sys.exit(1)
        print(commit)
    elif arguments == ["log", "-1", "--format=%s"]:
        print(configuration.get("subject", "fix: application change"))
    elif arguments[:2] == ["diff", "--name-only"]:
        print(configuration.get("changes", "pyproject.toml\nuv.lock\nCHANGELOG.md"))
    elif arguments[:1] == ["config"]:
        print("Release Fixture")
    elif arguments[:1] == ["add"]:
        sys.exit(configuration.get("add_status", 0))
    else:
        raise RuntimeError(f"Unexpected mock git operation: {arguments}")
elif command == "uv":
    if "semantic-release" in arguments:
        if "--print" in arguments:
            if configuration.get("probe_status", 0):
                print("Synthetic version probe failed", file=sys.stderr)
                sys.exit(configuration["probe_status"])
            print(configuration.get("next_version", "2.0.1"))
        else:
            sys.exit(configuration.get("publish_status", 0))
    elif arguments[:1] == ["lock"]:
        sys.exit(configuration.get("lock_status", 0))
    else:
        python = arguments.index("python")
        sys.exit(subprocess.call([sys.executable, *arguments[python + 1 :]]))
elif command == "gh":
    if arguments[:2] == ["release", "view"]:
        sys.exit(configuration.get("view_status", 0))
    if arguments[:2] == ["release", "upload"]:
        sys.exit(configuration.get("upload_status", 0))
elif command == "make":
    sys.exit(configuration.get("build_status", 0) if "build-package" in arguments else 0)
else:
    raise RuntimeError(f"Unexpected mock executable: {command}")
