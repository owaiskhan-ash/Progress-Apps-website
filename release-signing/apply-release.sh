#!/usr/bin/env bash
# Applies the release-signing + transition fixes to Project-Progress-Widget and
# publishes v1.2.2. Run it from a clone of that repository.
#
#   ./release-signing/apply-release.sh                 # dry run: applies, builds nothing, stops
#   ./release-signing/apply-release.sh --push          # commit, push main, tag v1.2.2
#   REPO_DIR=~/code/Project-Progress-Widget ./release-signing/apply-release.sh --push
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="1.2.2"
TAG="v$VERSION"
PUSH=0
for arg in "$@"; do
  case "$arg" in
    --push) PUSH=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

REPO_DIR="${REPO_DIR:-.}"
cd "$REPO_DIR"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not a git repository: $REPO_DIR" >&2; exit 1; }
[ -f app/build.gradle ] && [ -f app/src/main/AndroidManifest.xml ] || {
  echo "run this inside a Project-Progress-Widget clone (app/build.gradle not found)" >&2; exit 1; }

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "working tree is not clean; commit or stash first" >&2; exit 1
fi

git checkout main
git pull --ff-only origin main

echo "==> applying patch"
git apply --check "$HERE/android-release-v1.2.2.patch"
git apply "$HERE/android-release-v1.2.2.patch"

echo "==> installing release keystore"
mkdir -p keystore
cp "$HERE/keystore/progress-tracker.p12" "$HERE/keystore/README.md" keystore/

echo "==> files changed"
git status --short
grep -E "versionCode|versionName" app/build.gradle

if [ "$PUSH" -eq 0 ]; then
  cat <<EOF

Dry run only. The changes are in your working tree so you can review or build them:

  gradle assembleRelease        # needs JDK 17 + Android SDK 35

To commit, push and trigger the $TAG release:

  ./release-signing/apply-release.sh --push

EOF
  exit 0
fi

echo "==> committing and pushing"
git add -A
git commit -m "Signed release build, v$VERSION

- release signing config backed by keystore/ (see keystore/README.md)
- CI builds assembleRelease, verifies the signature, publishes
  Progress-tracker-v$VERSION.apk plus a stable progress-tracker.apk
- darker, quieter transitions: fade in place from black, only on page
  changes, with a dedicated milestone transition"
git push origin main

echo "==> tagging $TAG"
git tag -a "$TAG" -m "Project tracker $VERSION — signed release APK"
git push origin "$TAG"

cat <<EOF

Done. GitHub Actions is now building the signed APK:
  https://github.com/owaiskhan-ash/Project-Progress-Widget/actions

When the run finishes, the release appears at:
  https://github.com/owaiskhan-ash/Project-Progress-Widget/releases/tag/$TAG

Reminder: v1.2.0 and earlier were signed with a different (debug) key, so they
need one uninstall before installing $VERSION.
EOF
