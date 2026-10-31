"""Shared project, artifact and command fixtures for isolated release tests."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

from packaging.version import Version
import pytest

ROOT = Path(__file__).resolve().parents[3]


@pytest.fixture
def write_project():
    def create(path, name="demo-package", version="2.0.0"):
        path.mkdir(parents=True, exist_ok=True)
        (path / "pyproject.toml").write_text(f'[project]\nname = "{name}"\nversion = "{version}"\n')

    return create


@pytest.fixture
def write_artifacts():
    def create(path, name="demo_package", version="2.0.0"):
        directory = path / "dist"
        directory.mkdir(exist_ok=True)
        normalized = str(Version(version))
        files = [
            directory / f"{name}-{normalized}-py3-none-any.whl",
            directory / f"{name}-{normalized}.tar.gz",
        ]
        for file in files:
            file.touch()
        return files

    return create


@pytest.fixture
def run_release_recipe(tmp_path, write_project):
    scripts = tmp_path / "scripts"
    scripts.mkdir()
    shutil.copyfile(ROOT / "scripts/release_artifacts.py", scripts / "release_artifacts.py")
    write_project(tmp_path)
    binary = tmp_path / "bin"
    binary.mkdir()
    for name in ("git", "uv", "gh", "make"):
        executable = binary / name
        executable.write_text(
            f"#!{sys.executable}\n"
            + (Path(__file__).parent / "fixtures/release_command.py").read_text()
        )
        executable.chmod(0o755)
    source = (ROOT / "makefiles/release.mk").read_text()
    for name in ("release-version", "release-assets", "release"):
        source = source.replace(f"\n{name}:", f"\nfixture-{name}:")
    makefile = tmp_path / "fixture.mk"
    makefile.write_text(source)

    def run(target="release-version", **configuration):
        calls = tmp_path / "calls.jsonl"
        output = tmp_path / "output"
        calls.unlink(missing_ok=True)
        output.unlink(missing_ok=True)
        env = {
            **os.environ,
            "PATH": str(binary) + os.pathsep + os.environ["PATH"],
            "GH_TOKEN": "synthetic-fixture",
            "GIT_COMMIT_AUTHOR": "Release Fixture",
            "GITHUB_ACTIONS": configuration.pop("actions", "false"),
            "GITHUB_SHA": configuration.pop("sha", ""),
            "GITHUB_OUTPUT": str(output),
            "RELEASE_TEST_CASE": json.dumps(configuration),
            "RELEASE_TEST_CALLS": str(calls),
        }
        result = subprocess.run(
            [
                "/usr/bin/make",
                "--no-print-directory",
                "-j4",
                "-f",
                str(makefile),
                f"fixture-{target}",
                f"UV={binary / 'uv'}",
                f"MAKE={binary / 'make'}",
                "PACKAGE_PROJECTS=.",
            ],
            cwd=tmp_path,
            env=env,
            text=True,
            capture_output=True,
            timeout=20,
        )
        events = [json.loads(line) for line in calls.read_text().splitlines()]
        values = (
            dict(line.split("=", 1) for line in output.read_text().splitlines())
            if output.exists()
            else {}
        )
        return result, events, values

    return run
