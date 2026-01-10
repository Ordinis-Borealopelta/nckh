#!/bin/bash

set -e

echo "=== NCKH Doppler Setup ==="
echo ""

# Check if Doppler CLI is installed
if ! command -v doppler &> /dev/null; then
    echo "Error: Doppler CLI is not installed."
    echo "Install it with: curl -Ls https://cli.doppler.com/install.sh | sh"
    exit 1
fi

# Check if logged in
if ! doppler me &> /dev/null; then
    echo "Error: Not logged in to Doppler."
    echo "Run: doppler login"
    exit 1
fi

PROJECT_NAME="nckh"

echo "Setting up Doppler project: ${PROJECT_NAME}"
echo ""

# Create project (ignore error if already exists)
doppler projects create "${PROJECT_NAME}" --description "NCKH monorepo secrets" 2>/dev/null || true

# Setup local directory to use this project
doppler setup --project "${PROJECT_NAME}" --config dev --no-interactive 2>/dev/null || \
    echo "  - Run 'doppler setup' manually if needed"

echo "  ✓ Project ${PROJECT_NAME} ready"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Add secrets via Doppler dashboard: https://dashboard.doppler.com"
echo "2. Or use CLI: doppler secrets set KEY=value -p ${PROJECT_NAME} -c dev"
echo ""
echo "Required secrets:"
echo ""
echo "  - AUTH_DATABASE_URL (PostgreSQL, schema: public)"
echo "  - ACADEMIC_DATABASE_URL (PostgreSQL, schema: academic)"
echo "  - CERTIFICATION_DATABASE_URL (PostgreSQL, schema: certification)"
echo "  - BETTER_AUTH_SECRET"
echo ""
echo "To run a service with Doppler:"
echo "  bun run dev"
