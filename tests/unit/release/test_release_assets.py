"""Check upload prerequisites, prerelease filenames and build-before-upload behavior."""

import pytest


def test_prerelease_upload_preserves_tag_spelling(
    tmp_path, run_release_recipe, write_project, write_artifacts
):
    write_project(tmp_path, version="2.1.0-rc.1")
    write_artifacts(tmp_path, version="2.1.0-rc.1")
    result, events, _ = run_release_recipe(
        "release-assets", tags={"2.1.0-rc.1": "tested"}, view_status=1
    )
    assert result.returncode == 0, result.stderr
    create = next(event for event in events if event[:3] == ["gh", "release", "create"])
    upload = next(event for event in events if event[:3] == ["gh", "release", "upload"])
    assert create[3] == upload[3] == "v2.1.0-rc.1"
    assert "--prerelease" in create
    assert any("2.1.0rc1" in argument for argument in upload)


def test_missing_artifacts_prevent_github_operations(run_release_recipe):
    result, events, _ = run_release_recipe("release-assets")
    assert result.returncode != 0
    assert not any(event[0] == "gh" for event in events)


@pytest.mark.parametrize("build_status", [0, 42])
def test_parallel_release_builds_before_upload(run_release_recipe, build_status):
    result, events, _ = run_release_recipe(
        "release", tags={"2.0.0": "tested"}, build_status=build_status
    )
    commands = [event[-1] for event in events if event[0] == "make"]
    assert commands.index("release-version") < commands.index("build-package")
    assert (result.returncode == 0) == (build_status == 0)
    assert ("release-assets" in commands) == (build_status == 0)
    if build_status == 0:
        assert commands.index("build-package") < commands.index("release-assets")
