#!/bin/bash

TICKET="$1"
REPO_PATH="$HOME/Desktop/Test/${TICKET}Test++/us-qcells-salesforce"
PARENT_BRANCH="feature/PBD-$TICKET"
PROMO_BRANCHES=(
  "promotion/PBD-$TICKET-dev"
  "promotion/PBD-$TICKET-qa"
  "promotion/PBD-$TICKET-uat"
)

cd "$REPO_PATH" || {
  osascript -e "display alert \"Error\" message \"Repository path not found: $REPO_PATH\""
  exit 1
}

git config core.ignorecase false

if [ -d ".git/refs/heads/Promotion" ]; then
  rm -rf .git/refs/heads/Promotion
fi

git branch --list "promotion/*" | xargs -r -n 1 git branch -D 2>/dev/null

git fetch --all --prune >/dev/null 2>&1

if git show-ref --verify --quiet "refs/heads/$PARENT_BRANCH"; then
  git checkout "$PARENT_BRANCH" >/dev/null 2>&1
elif git show-ref --verify --quiet "refs/remotes/origin/$PARENT_BRANCH"; then
  git checkout -b "$PARENT_BRANCH" "origin/$PARENT_BRANCH" >/dev/null 2>&1
else
  osascript -e "display alert \"Error\" message \"Parent branch $PARENT_BRANCH not found locally or remotely!\""
  exit 1
fi

git pull origin "$PARENT_BRANCH" >/dev/null 2>&1

for branch in "${PROMO_BRANCHES[@]}"; do
  git branch -f "$branch" "$PARENT_BRANCH" >/dev/null 2>&1
  git push -u origin "$branch" --force >/dev/null 2>&1
done

git checkout "$PARENT_BRANCH" >/dev/null 2>&1

for branch in "${PROMO_BRANCHES[@]}"; do
  git branch -D "$branch" >/dev/null 2>&1
done

git for-each-ref --format='%(refname)' refs/heads/ | grep -i '^refs/heads/Promotion/' | while read ref; do
  git update-ref -d "$ref"
done
git for-each-ref --format='%(refname)' refs/remotes/origin/ | grep -i '^refs/remotes/origin/Promotion/' | while read ref; do
  git update-ref -d "$ref"
done
git gc --prune=now >/dev/null 2>&1
git fetch --all --prune >/dev/null 2>&1
git remote prune origin >/dev/null 2>&1
