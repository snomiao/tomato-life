#!/bin/sh
# The default branch was renamed master -> main on GitHub (2026-09-27).
# Move a clone that still has a local master over to main. Safe to run repeatedly.

git show-ref -q --verify refs/heads/master || exit 0
git fetch -q origin main 2>/dev/null || exit 0

if git show-ref -q --verify refs/heads/main; then
    # A stale master fully merged into main has nothing worth keeping
    if git merge-base --is-ancestor master main; then
        git branch -q -D master
        git fetch -q --prune origin
        echo "[fix-default-branch] deleted stale local master (already in main)" >&2
    else
        echo "[fix-default-branch] local master has commits not in main; leaving it alone" >&2
    fi
    exit 0
fi

git branch -m master main
git branch -q -u origin/main main
git remote set-head origin -a >/dev/null
echo "[fix-default-branch] renamed local master -> main, tracking origin/main" >&2
