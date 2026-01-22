#!/bin/bash
# Post-create script for GitHub Codespaces

set -e

echo "🚀 Setting up MTG Estimator in GitHub Codespaces..."

# Update packages
echo "📦 Updating packages..."
sudo apt-get update > /dev/null 2>&1

# Install system dependencies
echo "📥 Installing system dependencies..."
sudo apt-get install -y \
  imagemagick \
  libmagick++-dev \
  libmagickcore-dev \
  libmagickwand-dev \
  pkg-config \
  > /dev/null 2>&1

# Install Ruby gems
echo "💎 Installing Ruby gems..."
bundle install

# Create uploads directory if it doesn't exist
mkdir -p uploads

echo "✅ Setup complete!"
echo ""
echo "📝 To start the server, run:"
echo "   bundle exec puma config.ru -b tcp://0.0.0.0:5000"
echo ""
echo "🧪 To build the frontend, run:"
echo "   cd frontend && npm install && npm run build && cd .."
echo ""
