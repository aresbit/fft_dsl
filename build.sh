#!/bin/bash
set -e

echo "Building FFT DSL compiler..."

# Clean previous builds
echo "Cleaning previous builds..."
dune clean 2>/dev/null || true

# Clean and build
dune clean 2>/dev/null || true
dune build

echo "✓ Compiler built successfully"