import json
import sys
import tomllib
from pathlib import Path
from subprocess import run, PIPE
from typing import Any


def load_toml(path: str) -> dict[str, Any]:
    with open(path, "rb") as fh:
        return tomllib.load(fh)


def project_name(path: str) -> str | None:
    data = load_toml(path)
    name = data.get("project", {}).get("name", "")
    if isinstance(name, str) and name:
        return name
    return None


def dependency_names(current_project_path: str) -> set[str]:
    data = load_toml(current_project_path)
    sources = data.get("tool", {}).get("uv", {}).get("sources", {})
    if not isinstance(sources, dict):
        return set()
    return {name for name in sources.keys() if isinstance(name, str)}


def find_pyprojects() -> set[Path]:
    proc = run(["rg", "--files"], check=True, stdout=PIPE, stderr=PIPE, text=True)

    pyprojects: set[Path] = set()
    for line in proc.stdout.splitlines():
        if line.endswith("pyproject.toml"):
            pyprojects.add(Path(line))
    return pyprojects


def main(current_project_path: str) -> None:
    deps = dependency_names(current_project_path)
    names: dict[str, bool] = {}
    current_name = project_name(current_project_path)
    pyprojects = find_pyprojects()
    pyprojects.add(Path(current_project_path).resolve())

    for path in pyprojects:
        name = project_name(str(path))
        if name:
            names[name] = name in deps

    json.dump({"project_name": current_name, "names": names}, sys.stdout)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        json.dump({}, sys.stdout)
        raise SystemExit(0)

    main(sys.argv[1])
