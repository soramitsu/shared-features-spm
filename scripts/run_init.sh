#!/bin/bash
set -e
export LANG=en_US.UTF-8

echo "👋 Hey! Let's start to setup your environment"

# Install git hooks
echo "📦 Installing git hooks..."
mkdir -p .git/hooks
chmod +x ./hooks/pre-commit
ln -s -f ../../hooks/pre-commit .git/hooks/pre-commit
echo "✅ Git hooks installed!"

echo "🎉 All done! Enjoy your new environment!\n\nFor more commands run 'make help'"
