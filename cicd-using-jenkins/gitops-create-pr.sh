#!/usr/bin/env bash
# Jenkins -> GitOps: create a PR updating one image tag. No cluster access.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 backend|frontend BUILD_NUMBER" >&2
  exit 2
fi
component="$1"
tag="$2"
case "$component" in
  backend)  app="student-api"; manifest="kubernetes/apps/student-management/backend.yaml"; image="hoang4325/student-app-api" ;;
  frontend) app="student-web"; manifest="kubernetes/apps/student-management/frontend.yaml"; image="hoang4325/student-app-web" ;;
  *) echo "Unknown component: $component" >&2; exit 2 ;;
esac
if [[ ! "$tag" =~ ^[0-9]+$ ]]; then
  echo "Image tag must be numeric Jenkins BUILD_NUMBER" >&2
  exit 2
fi
: "${GH_TOKEN:?Set GH_TOKEN from Jenkins Secret text credentials}"
for tool in git gh python3; do
  command -v "$tool" >/dev/null || { echo "Missing command: $tool" >&2; exit 1; }
done

repo="hoang4325/Openstack-Cloud-Native-Private"
branch="ci/jenkins-$app-$tag"
workdir="$(mktemp -d)"
trap 'rm -rf -- "$workdir"' EXIT

git clone --quiet --depth 1 --branch master "https://github.com/$repo.git" "$workdir/infra"
cd "$workdir/infra"
git switch -c "$branch"
git config user.name "Jenkins GitOps"
git config user.email "jenkins-gitops@users.noreply.github.com"

# Change just the expected Deployment's image ref, and fail closed if missing/ambiguous.
python3 - "$manifest" "$image" "$tag" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
image_repo = sys.argv[2]
tag = sys.argv[3]
text = path.read_text(encoding="utf-8")
pattern = re.compile(r"(?m)^([ \t]*image:[ \t]*)" + re.escape(image_repo) + r":[A-Za-z0-9_.-]+")
new_text, count = pattern.subn(
    lambda m: m.group(1) + image_repo + ":" + tag,
    text,
)
if count != 1:
    raise SystemExit("Expected exactly one matching image reference in " + str(path))
if new_text != text:
    path.write_text(new_text, encoding="utf-8")
PY

if git diff --quiet -- "$manifest"; then
  echo "GitOps image already matches $image:$tag; no PR necessary."
  exit 0
fi

git add -- "$manifest"
git diff --cached --check
git commit -m "ci(gitops): update $app to image tag $tag"

# GIT_ASKPASS gets the credential from the masked environment variable.
# Never store a token in the Git remote URL or repository files.
cat > "$workdir/askpass" <<'SH'
#!/bin/sh
case "$1" in
  *Username*) printf '%s\n' 'x-access-token' ;;
  *Password*) printf '%s\n' "$GH_TOKEN" ;;
  *) exit 1 ;;
esac
SH
chmod 700 "$workdir/askpass"

GIT_ASKPASS="$workdir/askpass" GIT_TERMINAL_PROMPT=0 \
  git push --quiet origin "HEAD:refs/heads/$branch"

cat > "$workdir/pr-body.md" <<PR
Automated image update from Jenkins.

- Application: $app
- Docker image: $image:$tag
- Source commit: ${GIT_COMMIT:-unknown}
- Jenkins build: ${BUILD_URL:-unknown}
- Scope: only the image tag in $manifest.
- Database, Secret, PVC and infrastructure: unchanged.

Review and merge this PR. Argo CD remains in manual-sync mode until explicitly enabled.
PR

gh pr create \
  --repo "$repo" \
  --base master \
  --head "$branch" \
  --title "ci(gitops): deploy $app:$tag" \
  --body-file "$workdir/pr-body.md"
