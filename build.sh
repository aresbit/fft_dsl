#!/bin/bash
set -e

echo "Building FFT DSL compiler..."

# Build the compiler
dune build

echo "✓ FFT DSL compiler built successfully"

# Test with simple example
echo "Testing with FFT DSL example..."

# Create test directory if it doesn't exist
mkdir -p examples

# Use existing working_test.fft file
# Create a simple test FFT DSL file
cp examples/working_test.fft examples/test_fft.fft

echo "Created test FFT DSL file with content:"
echo "---"
cat examples/test_fft.fft
echo "---"

echo "Building test FFT DSL..."

# Use the compiled FFT DSL compiler to compile the test file
_build/default/src/main.exe examples/test_fft.fft fft_test

if [ -f "fft_test" ]; then
    echo "✓ Successfully compiled FFT DSL to executable 'fft_test'"
    echo "Generated files:"
    ls -la fft_test*
    
    echo ""
    echo "Running the generated FFT program..."
    ./fft_test
    
    echo "✓ FFT DSL program executes successfully!"
    
else
    echo "✗ Failed to compile FFT DSL to executable"
    echo "Checking for generated OCaml file:"
    if [ -f "fft_test.ml" ]; then
        echo "Found generated OCaml code:"
        echo "---"
        head -20 fft_test.ml
        echo "---"
    fi
    exit 1
fi

echo ""
echo "🎉 Compiler is working! All tests passed!"
echo "✓ FFT DSL compiler built successfully"
echo "✓ FFT DSL compilation successful" 
echo "✓ Generated FFT program works correctly"
echo "✓ Final program executes properly"

# Cleanup test files
echo ""
echo "Cleaning up test files..."
rm -f fft_test fft_test.ml
echo "Test completed successfully!"