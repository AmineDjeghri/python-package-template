"""Verify complete wheel/sdist sets and release version spelling."""

from pathlib import Path
import runpy

import pytest

ROOT = Path(__file__).resolve().parents[3]
METADATA = runpy.run_path(str(ROOT / "scripts/release_artifacts.py"))


@pytest.mark.parametrize("version", ["2.0.0", "2.1.0-rc.1"])
@pytest.mark.parametrize("projects", [["."], ["backend", "frontend"]])
def test_release_tag_and_complete_artifacts(
    tmp_path, monkeypatch, version, projects, write_project, write_artifacts
):
    monkeypatch.chdir(tmp_path)
    write_project(tmp_path, version=version)
    expected = []
    for index, project in enumerate(projects):
        name = f"package-{index}"
        write_project(tmp_path / project, name, version)
        expected.extend(write_artifacts(tmp_path, name.replace("-", "_"), version))
    assert METADATA["release_tag"]() == f"v{version}"
    actual = METADATA["release_artifacts"]([Path(project) for project in projects])
    assert [tmp_path / file for file in actual] == expected


@pytest.mark.parametrize("missing", [0, 1, 2, 3])
def test_partial_workspace_artifacts_are_rejected(
    tmp_path, monkeypatch, missing, write_project, write_artifacts
):
    monkeypatch.chdir(tmp_path)
    write_project(tmp_path)
    files = []
    for name in ("backend", "frontend"):
        write_project(tmp_path / name, name)
        files.extend(write_artifacts(tmp_path, name))
    files[missing].unlink()
    with pytest.raises(ValueError, match="one wheel and one sdist"):
        METADATA["release_artifacts"]([Path("backend"), Path("frontend")])


def test_mismatched_workspace_versions_are_rejected(tmp_path, monkeypatch, write_project):
    monkeypatch.chdir(tmp_path)
    write_project(tmp_path)
    write_project(tmp_path / "backend", version="1.9.0")
    with pytest.raises(ValueError, match="must have version 2.0.0"):
        METADATA["release_artifacts"]([Path("backend")])
