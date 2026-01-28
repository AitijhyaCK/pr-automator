#!/bin/bash

INSTALL_DIR="$HOME/.pr-automator/bin"

mkdir -p "$INSTALL_DIR"

echo "🚀 Installing PR Automator..."

curl -fsSL https://raw.githubusercontent.com/aitijhya/pr-automator/main/scripts/create_promotion_branch.sh \
  -o "$INSTALL_DIR/create-promotion-branch"

curl -fsSL https://raw.githubusercontent.com/aitijhya/pr-automator/main/scripts/create_ticket_folder.sh \
  -o "$INSTALL_DIR/create-ticket-folder"

curl -fsSL https://raw.githubusercontent.com/aitijhya/pr-automator/main/scripts/create_pr_description.sh \
  -o "$INSTALL_DIR/create-pr-description"

chmod +x "$INSTALL_DIR/"*

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> ~/.zshrc
  echo "ℹ️ Added pr-automator to PATH. Restart terminal."
fi

echo "✅ Installation complete"
