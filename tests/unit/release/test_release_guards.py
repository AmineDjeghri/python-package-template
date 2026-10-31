"""Check release preconditions and failures without real publication."""

import json
import os
from pathlib import Path
import subprocess
import tomllib

import pytest

ROOT = Path(__file__).resolve().parents[3]


@pytest.mark.parametrize(
    "configuration",
    [
        {"branch": "feature/example"},
        {"dirty": True},
        {"fetch_status": 1},
        {"origin": "another-commit"},
        {"actions": "true", "sha": "tested", "head": "newer"},
        {
            "actions": "true",
            "sha": "tested",
            "head": "release",
            "tags": {"2.0.0": "release"},
            "parent": "unvalidated",
            "subject": "chore(release): v2.0.0 [skip ci]",
        },
        {
            "actions": "true",
            "sha": "tested",
            "head": "release",
            "tags": {"2.0.0": "release"},
            "parent": "tested",
            "subject": "fix: untested application change",
        },
        {
            "actions": "true",
            "sha": "tested",
            "head": "release",
            "tags": {"2.0.0": "release"},
            "parent": "tested",
            "subject": "chore(release): v2.0.0 [skip ci]",
            "changes": "backend/src/application.py",
        },
        {
            "actions": "true",
            "sha": "tested",
            "head": "release",
            "tags": {"2.0.0": "release"},
            "parent": "tested",
            "subject": "chore(release): v2.0.0 [skip ci]",
            "merge": True,
        },
    ],
)
def test_invalid_release_state_never_versions(run_release_recipe, configuration):
    result, events, _ = run_release_recipe(**configuration)
    assert result.returncode != 0
    assert not any("semantic-release" in event for event in events)


def test_failed_version_probe_is_an_error(run_release_recipe):
    result, _, values = run_release_recipe(probe_status=42)
    assert result.returncode != 0
    assert "Synthetic version probe failed" in result.stderr
    assert "No releasable commit" not in result.stdout
    assert values.get("released") != "true"


def test_no_releasable_commit_does_not_publish(run_release_recipe):
    result, events, values = run_release_recipe(next_version="2.0.0", tags={"2.0.0": "older"})
    assert result.returncode == 0, result.stderr
    assert values["released"] == values["tagged"] == "false"
    assert not any("-v" in event for event in events)


def test_validated_commit_can_release(run_release_recipe):
    result, _, values = run_release_recipe(actions="true", sha="tested")
    assert result.returncode == 0, result.stderr
    assert values["released"] == values["tagged"] == "true"
    assert values["tag"] == "v2.0.1"


def test_generated_release_commit_can_recover_uploads(run_release_recipe):
    result, events, values = run_release_recipe(
        actions="true",
        sha="tested",
        head="release",
        parent="tested",
        tags={"2.0.0": "release"},
        subject="chore(release): v2.0.0 [skip ci]",
    )
    assert result.returncode == 0, result.stderr
    assert values["released"] == "false"
    assert values["tagged"] == "true"
    assert not any("semantic-release" in event for event in events)


@pytest.mark.parametrize("failure", ["lock_status", "add_status", "build_status"])
def test_release_build_hook_stops_at_first_failure(tmp_path, run_release_recipe, failure):
    run_release_recipe()  # Prepare isolated executable mocks.
    configuration = tomllib.loads((ROOT / "pyproject.toml").read_text())
    command = configuration["tool"]["semantic_release"]["build_command"]
    calls = tmp_path / "hook-calls"
    result = subprocess.run(
        ["/bin/sh", "-c", command],
        cwd=tmp_path,
        env={
            **os.environ,
            "PATH": str(tmp_path / "bin") + os.pathsep + os.environ["PATH"],
            "RELEASE_TEST_CASE": json.dumps({failure: 42}),
            "RELEASE_TEST_CALLS": str(calls),
            "PACKAGE_NAME": "demo-package",
        },
        capture_output=True,
        text=True,
        timeout=20,
    )
    assert result.returncode != 0
    events = [json.loads(line) for line in calls.read_text().splitlines()]
    expected = {"lock_status": 1, "add_status": 2, "build_status": 3}
    assert len(events) == expected[failure]
