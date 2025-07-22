# FFT DSL Compiler

A domain-specific language compiler for generating FFT implementations using the Cooley-Tukey Radix-2 algorithm.

## Building

```bash
./build.sh
```

## Usage

```bash
# Compile FFT DSL file
dune exec -- src/main.exe input.fft output_executable

# Or use the built version
_build/default/src/main.exe input.fft output_executable
```

## Example FFT DSL

```
fft fft_radix2 size 4 {
    base_case when size == 1 {
        output[0] = input[0]
    }
    recursive {
        for k = 0 to 1 do
            t = W_2^k * fft_odd[k]
            output[k] = fft_even[k] + t
            output[k + 1] = fft_even[k] - t
        done
    }
}
```

## Project Structure

- `src/ast.ml` - Abstract syntax tree definitions
- `src/lexer.mll` - Lexical analyzer
- `src/parser.mly` - Parser
- `src/semantic.ml` - Semantic analysis
- `src/codegen.ml` - Code generation
- `src/main.ml` - Main compiler driver