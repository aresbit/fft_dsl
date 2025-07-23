#!/bin/bash
set -e

echo "Building FFT DSL compiler..."

# Clean previous builds
echo "Cleaning previous builds..."
dune clean 2>/dev/null || true

# Build the compiler
echo "Building compiler..."
dune build

if [ $? -eq 0 ]; then
    echo "✓ FFT DSL compiler built successfully"
else
    echo "✗ Failed to build FFT DSL compiler"
    exit 1
fi

# Test with simple example
echo "Testing with FFT DSL example..."

# Create test directory if it doesn't exist
mkdir -p examples

# Create a simple test FFT DSL file with better formatting
cat > examples/working_test.fft << 'EOF'
fft simple_fft size 4 {
  base_case when size = 1 {
    result = input
  }
  
  recursive {
    even = input[0]
    odd = input[1] 
    temp = mul W_4^0 odd
    output[0] = even + temp
    output[1] = even - temp
  }
}
EOF

echo "Created test FFT DSL file with content:"
echo "---"
cat examples/working_test.fft
echo "---"

echo "Compiling test FFT DSL..."

# Use the compiled FFT DSL compiler to compile the test file
_build/default/src/main.exe examples/working_test.fft fft_test

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
        head -30 fft_test.ml
        echo "---"
        echo ""
        echo "Trying to manually compile OCaml code..."
        ocamlc -o fft_test fft_test.ml
        if [ -f "fft_test" ]; then
            echo "✓ Manual compilation successful"
            ./fft_test
        fi
    fi
fi

echo ""
echo "🎉 Build completed!"

# Show available commands
echo ""
echo "You can now use the compiler with:"
echo "  _build/default/src/main.exe <input.fft> <output_name>"
echo ""
echo "Example:"
echo "  _build/default/src/main.exe examples/working_test.fft my_fft"

# Cleanup test files at user's discretion
read -p "Clean up test files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleaning up test files..."
    rm -f fft_test fft_test.ml fft_test.cmi fft_test.cmo
    echo "Test files cleaned up!"
fi