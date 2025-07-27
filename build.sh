#!/bin/bash

echo "=== FFT DSL 编译器构建和测试 ==="

# 创建目录结构
mkdir -p src examples

# 检查OCaml是否安装
if ! command -v ocamlc &> /dev/null; then
    echo "错误: OCaml 编译器未安装"
    echo "请安装OCaml: sudo apt-get install ocaml 或 brew install ocaml"
    exit 1
fi

# 构建编译器
echo "1. 构建FFT DSL编译器..."
if dune build; then
    echo "   ✓ 编译器构建成功!"
else
    echo "   ✗ 编译器构建失败!"
    exit 1
fi

# 创建测试FFT文件
echo "2. 创建测试文件..."
cat > examples/fft4.fft << 'EOF'
fft fft4 size 4 {
  base_case when size == 1 {
    output[0] = input[0]
  }
  recursive {
    even0 = input[0]
    even1 = input[2]
    odd0 = input[1]
    odd1 = input[3]
    
    g0 = even0 + even1
    g1 = even0 - even1
    
    h0 = odd0 + odd1
    h1 = odd0 - odd1
    
    w0 = W_4^0
    w1 = W_4^1
    
    w0h0 = mul w0 h0
    w1h1 = mul w1 h1
    
    output[0] = g0 + w0h0
    output[1] = g1 + w1h1
    output[2] = g0 - w0h0
    output[3] = g1 - w1h1
  }
}
EOF

# 编译FFT DSL文件
echo "3. 编译FFT DSL文件..."
dune exec -- src/main.exe examples/fft4.fft fft4

if [ $? -eq 0 ]; then
    echo "   ✓ FFT DSL编译成功!"
else
    echo "   ✗ FFT DSL编译失败!"
    exit 1
fi

# 测试生成的程序
echo "4. 测试生成的FFT程序..."
echo "   测试输入: [1+0i, 1+0i, 1+0i, 1+0i]"
./fft4 1 0 1 0 1 0 1 0

echo ""
echo "   测试输入: [1+0i, 0+0i, 0+0i, 0+0i]"
./fft4 1 0 0 0 0 0 0 0

echo ""
echo "=== 测试完成 ==="