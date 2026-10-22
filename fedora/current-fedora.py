#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
from contextlib import chdir
from pathlib import Path
from platform import freedesktop_os_release


def run_command(cmd, log_file=None):
    """Run a command, optionally logging stdout to a file, and print stderr tail on failure."""
    if log_file:
        with open(log_file, "w") as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)
    else:
        result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Command failed: {' '.join(str(c) for c in cmd)}", file=sys.stderr)
        stderr = result.stderr if result.stderr else "No stderr output"
        lines = stderr.strip().split("\n")
        tail = "\n".join(lines[-10:])
        print("Last output:", file=sys.stderr)
        print(tail, file=sys.stderr)
        raise RuntimeError(f"Command failed with exit code {result.returncode}")

    return result


def main():
    parser = argparse.ArgumentParser(description="Build metadata for Fedora version")
    parser.add_argument(
        "--archive-path",
        required=True,
        help="Path to the mirror of the repository",
    )
    args = parser.parse_args()

    os_release = freedesktop_os_release()

    archive_path = Path(args.archive_path)
    version = os_release.get("VERSION_ID")
    basedir = Path(__file__).parent.resolve()

    if os_release.get("ID") != "fedora":
        print("This script is only for Fedora", file=sys.stderr)
        sys.exit(1)

    # Check required dependencies
    required = ["appstream-builder", "appstream-util"]
    missing = []
    for cmd in required:
        result = subprocess.run(["command", "-v", cmd], shell=True, capture_output=True)
        if result.returncode != 0:
            missing.append(cmd)

    if missing:
        print(f"These dependencies are missing: {' '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    # Verify path to mirror is a directory
    if not archive_path.is_dir():
        print("Path to mirror needs to be a directory", file=sys.stderr)
        sys.exit(1)

    # Create logs directory
    logs_dir = basedir / "logs"
    try:
        logs_dir.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        print(f"./logs dir not present or readable: {e}", file=sys.stderr)
        sys.exit(1)

    # Download repositories
    print("Downloading repositories...")
    run_command(["dnf", "repolist", "--json"])
    result = subprocess.run(
        ["dnf", "repolist", "--json"], capture_output=True, text=True
    )
    repos = json.loads(result.stdout)
    repo_ids = [repo["id"] for repo in repos]

    for repo in repo_ids:
        log_file = f"{repo}.log"
        cmd = [
            "dnf",
            "reposync",
            "--setopt=*.module_hotfixes=1",
            "--repo",
            repo,
            "-p",
            archive_path / f"fedora-{version}",
        ]
        run_command(cmd, log_file=log_file)

    # Find package directories
    pkgs_dirs = []
    fedora_dir = archive_path / f"fedora-{version}"
    for dir_path in fedora_dir.glob("*/Packages"):
        if dir_path.is_dir():
            pkgs_dirs.append(f"--packages-dir={dir_path}")

    # Build applications
    print("Building applications...")
    output_dir = basedir / "metadata" / f"f{version}"
    temp_dir = basedir.parent / "tmp" / f"f{version}"
    cache_dir = basedir.parent / f"cache-f{version}"
    log_dir = basedir / "logs" / f"fedora-{version}"

    cmd = [
        "appstream-builder",
        "--verbose",
        "--veto-ignore=add-default-icons",
        "--min-icon-size=48",
        "--include-failed",
        f"--log-dir={log_dir}",
        f"--temp-dir={temp_dir}",
        f"--cache-dir={cache_dir}",
        *pkgs_dirs,
        f"--output-dir={output_dir}",
        f"--basename=fedora-{version}",
        "--origin=fedora",
    ]

    run_command(cmd, log_file=f"fedora-{version}.log")

    # Extract font screenshots
    print("Extracting font screenshots")
    source_dir = output_dir / "source"
    source_dir.mkdir(parents=True, exist_ok=True)

    with chdir(source_dir):
        tar_file = output_dir / f"fedora-{version}-screenshots.tar"
        run_command(["tar", "-xvf", tar_file])

    # Mirror screenshots
    print("Mirroring screenshots")
    xml_gz = output_dir / f"fedora-{version}.xml.gz"
    screenshots_uri = f"http://dl.fedoraproject.org/pub/alt/screenshots/f{version}"
    cmd = ["appstream-util", "mirror-screenshots"]
    cmd += [xml_gz, screenshots_uri, cache_dir, output_dir]
    run_command(cmd)

    # Create status pages
    print("Creating status pages")
    xml_failed_gz = output_dir / f"fedora-{version}-failed.xml.gz"

    out_yaml = output_dir / "applications-to-import.yaml"
    run_command(["appstream-util", "non-package-yaml", xml_gz, out_yaml])

    run_command(["appstream-util", "status-html", xml_gz, output_dir / "status.html"])

    failed_html = output_dir / "failed.html"
    run_command(["appstream-util", "status-html", xml_failed_gz, failed_html])

    matrix_html = output_dir / "matrix.html"
    run_command(["appstream-util", "matrix-html", xml_gz, xml_failed_gz, matrix_html])

    # Upload metadata
    print("Uploading new metadata")
    version_dir = f"f{version}"

    print("Setting permissions on screenshots")
    run_command(["chmod", "-R", "0444", version_dir])
    run_command(["chmod", "-R", "ug+rwX,o+rX", version_dir])

    print("Uploading screenshots")
    fedora_user = os.environ.get("FEDORA_USER", os.getlogin())
    ssh_url = f"{fedora_user}@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/"
    rsync_cmd = ["rsync", "--verbose", "--recursive", "--update", "--progress"]
    rsync_cmd += [version_dir, ssh_url]
    run_command(rsync_cmd)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
