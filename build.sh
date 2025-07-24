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

# Create a correct FFT DSL test file
cat > examples/working_test.fft << 'EOF'
fft simple_fft size 4 {
  base_case when size = 1 {
    result = input[0]
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
        echo "--- Generated OCaml Code (first 50 lines) ---"
        head -50 fft_test.ml
        echo "--- End of preview ---"
        echo ""
        echo "Trying to manually compile OCaml code..."
        ocamlc -o fft_test fft_test.ml
        if [ -f "fft_test" ]; then
            echo "✓ Manual compilation successful"
            echo "Running the program:"
            ./fft_test
        else
            echo "✗ Manual compilation also failed"
            echo "Checking OCaml compiler error:"
            ocamlc -o fft_test fft_test.ml 2>&1 || true
        fi
    else
        echo "✗ No OCaml file generated"
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

# Create additional test examples
echo ""
echo "Creating additional test examples..."

# Simple 2-point FFT
cat > examples/fft2.fft << 'EOF'
fft fft2 size 2 {
  base_case when size = 1 {
    result = input[0]
  }
  
  recursive {
    even = input[0] 
    odd = input[1]
    output[0] = even + odd
    output[1] = even - odd
  }
}
EOF

# 8-point FFT with twiddle factors
cat > examples/fft8.fft << 'EOF'
fft fft8 size 8 {
  base_case when size = 1 {
    result = input[0]
  }
  
  recursive {
    even = input[0]
    odd = input[1] 
    w = W_8^0
    temp = mul w odd
    output[0] = even + temp
    output[1] = even - temp
  }
}
EOF

echo "Created additional examples: fft2.fft and fft8.fft"

# Test the additional examples
echo ""
echo "Testing fft2.fft..."
_build/default/src/main.exe examples/fft2.fft fft2_test 2>/dev/null && {
    echo "✓ fft2.fft compiled successfully"
    ./fft2_test 2>/dev/null && echo "✓ fft2_test runs successfully" || echo "✗ fft2_test failed to run"
} || echo "✗ fft2.fft compilation failed"

echo ""
echo "Testing fft8.fft..."  
_build/default/src/main.exe examples/fft8.fft fft8_test 2>/dev/null && {
    echo "✓ fft8.fft compiled successfully"
    ./fft8_test 2>/dev/null && echo "✓ fft8_test runs successfully" || echo "✗ fft8_test failed to run"
} || echo "✗ fft8.fft compilation failed"

# Cleanup test files at user's discretion
echo ""
read -p "Clean up test files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleaning up test files..."
    rm -f fft_test fft_test.ml fft_test.cmi fft_test.cmo
    rm -f fft2_test fft2_test.ml fft2_test.cmi fft2_test.cmo  
    rm -f fft8_test fft8_test.ml fft8_test.cmi fft8_test.cmo
    echo "Test files cleaned up!"
fi