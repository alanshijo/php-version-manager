#!/bin/bash
# PHP Switch - Quick Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/alanshijo/php-version-manager/main/install.sh | bash

set -e

echo "🐘 Installing PHP Switch..."

# Download the script
curl -fsSL -o ~/.php-switch https://raw.githubusercontent.com/alanshijo/php-version-manager/main/php-switch.sh

# Detect shell and config file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

# Add source line if not already present
if ! grep -q "source ~/.php-switch" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# PHP Switch - PHP Version Manager" >> "$SHELL_CONFIG"
    echo "source ~/.php-switch" >> "$SHELL_CONFIG"
    echo "✅ Added to $SHELL_CONFIG"
else
    echo "ℹ️  Already configured in $SHELL_CONFIG"
fi

echo ""
echo "✨ PHP Switch installed successfully!"
echo ""
echo "To start using it, run:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Or restart your terminal, then try:"
echo "  php-switch --help"
echo "  php-list"
echo ""
