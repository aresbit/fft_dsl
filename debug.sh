#!/bin/bash

# FFT DSL 调试脚本

echo "=== FFT DSL 编译器调试工具 ==="
echo ""

# 检查必要的工具
echo "1. 检查依赖工具..."
echo -n "   OCaml: "
if command -v ocaml &> /dev/null; then
    ocaml -version
else
    echo "❌ 未安装"
fi

echo -n "   Dune: "
if command -v dune &> /dev/null; then
    dune --version
else
    echo "❌ 未安装"
fi

echo -n "   OCamlc: "
if command -v ocamlc &> /dev/null; then
    ocamlc -version
else
    echo "❌ 未安装"
fi

echo ""

# 检查项目结构
echo "2. 检查项目结构..."
required_files=(
    "src/main.ml"
    "src/ast.ml" 
    "src/lexer.mll"
    "src/parser.mly"
    "src/semantic.ml"
    "src/codegen.ml"
    "src/dune"
    "dune-project"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "   ✓ $file"
    else
        echo "   ❌ $file (缺失)"
    fi
done

echo ""

# 检查构建状态
echo "3. 检查构建状态..."
if [[ -d "_build" ]]; then
    echo "   ✓ 构建目录存在"
    if [[ -f "_build/default/src/main.exe" ]]; then
        echo "   ✓ 编译器可执行文件存在"
    else
        echo "   ❌ 编译器可执行文件不存在"
        echo "   → 尝试重新构建: dune build"
    fi
else
    echo "   ❌ 构建目录不存在"
    echo "   → 需要首次构建: dune build"
fi

echo ""

# 测试简单的FFT DSL文件
echo "4. 测试基本功能..."

# 创建最简单的测试文件
cat > debug_test.fft << 'EOF'
fft test size 2 {
  base_case when size = 1 {
    x = 1.0
  }
  recursive {
    y = 2.0
  }
}
EOF

echo "   创建了测试文件: debug_test.fft"

if [[ -f "_build/default/src/main.exe" ]]; then
    echo "   运行编译测试..."
    if _build/default/src/main.exe debug_test.fft debug_output 2> debug_error.log; then
        echo "   ✓ 编译成功"
        if [[ -f "debug_output" ]]; then
            echo "   ✓ 生成了可执行文件"
            echo "   测试运行..."
            if ./debug_output > debug_run.log 2>&1; then
                echo "   ✓ 程序运行成功"
                echo "   输出内容:"
                cat debug_run.log | head -10
            else
                echo "   ❌ 程序运行失败"
                echo "   错误信息:"
                cat debug_run.log
            fi
        else
            echo "   ❌ 未生成可执行文件"
        fi
    else
        echo "   ❌ 编译失败"
        echo "   错误信息:"
        cat debug_error.log
    fi
else
    echo "   ❌ 编译器不可用，需要先构建"
fi

echo ""

# 提供修复建议
echo "5. 修复建议..."

if ! command -v dune &> /dev/null; then
    echo "   📦 安装Dune: opam install dune"
fi

if ! command -v ocaml &> /dev/null; then
    echo "   📦 安装OCaml: opam switch create 4.14.0"
fi

if [[ ! -f "_build/default/src/main.exe" ]]; then
    echo "   🔨 构建编译器: dune build"
fi

echo "   📚 查看使用指南了解更多信息"

echo ""

# 清理调试文件
read -p "清理调试文件? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f debug_test.fft debug_output debug_output.ml debug_error.log debug_run.log
    rm -f debug_output.cmi debug_output.cmo
    echo "✓ 调试文件已清理"
fi

echo ""
echo "=== 调试完成 ====="