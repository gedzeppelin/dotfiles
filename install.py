#!/usr/bin/env python3
from __future__ import annotations

import argparse
import filecmp
import os
import shutil
import subprocess
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

ROOT = Path(__file__).resolve().parent
HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config")).expanduser()


@dataclass(init=False)
class Target:
    src: Path
    dst: Path
    type: Literal["directory", "file"]

    def __init__(
        self,
        src: str,
        dst: str | None = None,
        *,
        prefix: Path = CONFIG,
        type: Literal["directory", "file"] = "directory",
    ) -> None:
        self.src = Path(src)
        self.dst = (prefix / (dst or src)).expanduser()
        self.type = type


DEPS: dict[str, Target | list[Target]] = {
    "atuin": Target("atuin"),
    "kitty": Target("kitty"),
    "nvim": Target("nvim/init.lua", type="file"),
    "sway": Target("sway"),
    "tmux": Target("tmux/tmux.conf", ".tmux.conf", prefix=HOME, type="file"),
    "tofi": Target("tofi"),
    "waybar": Target("waybar"),
    "yazi": Target("yazi"),
    "zsh": Target("zsh/zshrc", ".zshrc", prefix=HOME, type="file"),
}


def as_targets(targets: Target | list[Target]) -> list[Target]:
    if isinstance(targets, Target):
        return [targets]
    return targets


def choose(names: list[str]) -> list[tuple[str, list[Target]]]:
    return [(name, as_targets(DEPS[name])) for name in names or DEPS]


def parse(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Manage dotfiles.",
        epilog=f"Targets: {' '.join(DEPS)}",
    )
    commands = parser.add_subparsers(dest="command", required=True)

    install = commands.add_parser("install", help="copy files to the host")
    install.add_argument(
        "--dry-run",
        action="store_true",
        help="preview install operations without writing files",
    )
    install.set_defaults(run=run_install)

    check = commands.add_parser("check", help="report drift")
    check.set_defaults(run=run_check)

    diff = commands.add_parser("diff", help="interactively review and resolve drift")
    diff.set_defaults(run=run_diff)

    listing = commands.add_parser("list", help="list targets")
    listing.set_defaults(run=run_list)

    for command in (install, check, diff):
        command.add_argument(
            "names", nargs="*", metavar="target", help="targets to operate on"
        )

    args = parser.parse_args(argv)
    unknown = [name for name in getattr(args, "names", []) if name not in DEPS]
    if unknown:
        parser.error(f"unknown target(s): {' '.join(unknown)}")
    return args


def overwrite(path: Path) -> bool:
    return input(f"overwrite '{path}'? ").lower().strip() in {"y", "yes"}


def copy_file(src: Path, dst: Path, dry: bool) -> None:
    if dst.is_dir() and not dst.is_symlink():
        raise IsADirectoryError(f"Cannot overwrite directory with file: {dst}")
    if (dst.exists() or dst.is_symlink()) and not dry and not overwrite(dst):
        print(f"skip {dst}")
        return
    print(f"{src} -> {dst}")
    if dry:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst, follow_symlinks=False)


def install_target(target: Target, dry: bool) -> None:
    src, dst = ROOT / target.src, target.dst
    if target.type == "directory":
        for item in sorted(src.rglob("*")):
            rel = item.relative_to(src)
            if item.is_dir() and not item.is_symlink():
                if not dry:
                    (dst / rel).mkdir(parents=True, exist_ok=True)
            else:
                copy_file(item, dst / rel, dry)
    else:
        copy_file(src, dst, dry)


def files(path: Path) -> dict[Path, Path]:
    if path.is_file() or path.is_symlink():
        return {Path(): path}
    if not path.exists():
        return {}
    return {
        item.relative_to(path): item
        for item in path.rglob("*")
        if item.is_file() or item.is_symlink()
    }


def same(src: Path, dst: Path) -> bool:
    if src.is_symlink() or dst.is_symlink():
        return (
            src.is_symlink()
            and dst.is_symlink()
            and os.readlink(src) == os.readlink(dst)
        )
    return filecmp.cmp(src, dst, shallow=False)


@dataclass(frozen=True)
class Mismatch:
    dep: str
    repo: Path
    host: Path
    repo_name: Path
    host_name: Path
    repo_exists: bool
    host_exists: bool

    def describe(self) -> str:
        if not self.repo_exists:
            return f"host-only {self.dep}: {self.host_name}"
        if not self.host_exists:
            return f"repo-only   {self.dep}: {self.repo_name} -> {self.host_name}"
        return f"changed     {self.dep}: {self.repo_name} <> {self.host_name}"


def mismatches(dep: str, target: Target) -> list[Mismatch]:
    repo_root, host_root = ROOT / target.src, target.dst
    repo_files, host_files = files(repo_root), files(host_root)
    result = []
    for rel in sorted(repo_files.keys() | host_files.keys()):
        repo, host = repo_files.get(rel), host_files.get(rel)
        if repo is not None and host is not None and same(repo, host):
            continue
        result.append(
            Mismatch(
                dep=dep,
                repo=repo_root / rel,
                host=host_root / rel,
                repo_name=target.src / rel if rel.parts else target.src,
                host_name=target.dst / rel if rel.parts else target.dst,
                repo_exists=repo is not None,
                host_exists=host is not None,
            )
        )
    return result


def show_diff(mismatch: Mismatch) -> None:
    repo = mismatch.repo if mismatch.repo_exists else Path("/dev/null")
    host = mismatch.host if mismatch.host_exists else Path("/dev/null")
    subprocess.run(
        [
            "diff",
            "--unified",
            "--no-dereference",
            "--label",
            f"repository: {mismatch.repo_name}",
            "--label",
            f"host: {mismatch.host_name}",
            "--",
            str(repo),
            str(host),
        ],
        check=False,
    )


def remove_path(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    elif path.exists() or path.is_symlink():
        path.unlink()


def sync_path(src: Path, src_exists: bool, dst: Path) -> None:
    if not src_exists:
        print(f"remove {dst}")
        remove_path(dst)
        return

    print(f"{src} -> {dst}")
    remove_path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_symlink():
        dst.symlink_to(os.readlink(src))
    else:
        shutil.copy2(src, dst)


def resolve(mismatch: Mismatch) -> bool:
    while True:
        answer = (
            input("[s]kip, [h]ost -> repository, [r]epository -> host? ")
            .lower()
            .strip()
        )
        if answer in {"s", "skip"}:
            return False
        if answer in {"h", "host"}:
            sync_path(mismatch.host, mismatch.host_exists, mismatch.repo)
            return True
        if answer in {"r", "repo", "repository"}:
            sync_path(mismatch.repo, mismatch.repo_exists, mismatch.host)
            return True
        print("Please choose s, h, or r.")


def selected_mismatches(names: list[str]) -> list[Mismatch]:
    return [
        mismatch
        for name, targets in choose(names)
        for target in targets
        for mismatch in mismatches(name, target)
    ]


def run_install(args: argparse.Namespace) -> int:
    for _name, targets in choose(args.names):
        for target in targets:
            install_target(target, args.dry_run)
    return 0


def run_check(args: argparse.Namespace) -> int:
    dirty = selected_mismatches(args.names)
    for mismatch in dirty:
        print(mismatch.describe())
    if not dirty:
        print("No drift.")
    return 1 if dirty else 0


def run_diff(args: argparse.Namespace) -> int:
    dirty = selected_mismatches(args.names)
    if not dirty:
        print("No drift.")
        return 0

    for mismatch in dirty:
        print(mismatch.describe(), flush=True)
        show_diff(mismatch)
        try:
            resolve(mismatch)
        except OSError as error:
            print(f"error: {error}", file=sys.stderr)

    remaining = selected_mismatches(args.names)
    if not remaining:
        print("All mismatches resolved.")
    return 1 if remaining else 0


def run_list(_args: argparse.Namespace) -> int:
    print(" ".join(DEPS))
    return 0


def main(argv: list[str]) -> int:
    args = parse(argv)
    run: Callable[[argparse.Namespace], int] = args.run
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
