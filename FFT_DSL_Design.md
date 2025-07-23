# FFT DSL 语法设计文档

## 概述

基于Radix-2 FFT算法原理，设计一套优雅、直观的领域特定语言（DSL），用于描述和实现快速傅里叶变换计算。该DSL旨在让数学表达式的书写尽可能接近传统的数学符号，同时保持程序的可执行性。

## 核心语法设计

### 1. 基本数据类型

#### 复数 (Complex)
支持复数直接表示，使用标准数学格式：
```
a + bi
```

#### 序列 (Sequence)
表示输入信号序列，支持多种定义方式：
- 显式枚举: `[1+0i, 0+1i, -1+0i, 0-1i]`
- 范围生成: `0..N-1` 或 `range(0, N)`
- 函数映射: `map(n -> cos(2πn/N), 0..N-1)`

### 2. 核心操作符

#### 变换操作符
- `FFT`: 快速傅里叶变换
- `IFFT`: 逆快速傅里叶变换
- `DIT`: 时域抽取法 (Decimation in Time)
- `DIF`: 频域抽取法 (Decimation in Frequency)

#### 数学操作符
- `⊕`: 蝶形运算加 (Butterfly addition)
- `⊖`: 蝶形运算减 (Butterfly subtraction)
- `⊗`: 旋转因子乘法 (Twiddle factor multiplication)
- `⊙`: 点乘 (Element-wise multiplication)

### 3. 蝶形运算语法

蝶形运算作为基本计算单元，提供简洁的语法：
```
butterfly(G[k], H[k], W_N^k) -> (X[k], X[k+N/2])
```

简化形式：
```
(G[k] ⊕ (W_N^k ⊗ H[k]), G[k] ⊖ (W_N^k ⊗ H[k]))
```

### 4. 递归结构语法

#### 分治结构
```
fft_recursive(sequence) {
    if length(sequence) == 1 {
        return sequence
    }
    
    even = sequence[::2]   # 偶数下标
    odd = sequence[1::2]   # 奇数下标
    
    G = fft_recursive(even)
    H = fft_recursive(odd)
    
    return combine(G, H, N, k)
}
```

#### 迭代结构
```
fft_iterative(sequence) {
    N = length(sequence)
    bit_reverse(sequence)
    
    for stage = 1 to log2(N) {
        for each butterfly in stage {
            butterfly_operation()
        }
    }
}
```

### 5. 旋转因子定义

旋转因子（Twiddle Factor）的优雅表示：
```
W_N^k = exp(-2πi * k / N)
```

支持预计算：
```
twiddle_table(N) = [exp(-2πi * k / N) for k in 0..N-1]
```

### 6. 高级语法特性

#### 模式匹配
```
match sequence_length {
    1 => sequence,
    N when is_power_of_two(N) => {
        even, odd = split(sequence)
        fft(even) ⊕ fft(odd)
    }
}
```

#### 管道操作
```
sequence 
    |> bit_reverse
    |> fft_stages
    |> normalize
```

### 7. 完整示例语法

#### 8点FFT优雅表示
```
let N = 8
let input = [1, 1, 1, 1, 0, 0, 0, 0]

let result = FFT(input, method=DIT) where {
    radix = 2
    normalize = true
    output_format = "polar"  # 极坐标形式输出
}
```

#### 数学表达式风格
```
X[k] = Σ_{n=0}^{N-1} x[n] * e^{-2πikn/N}
```

在DSL中的等价表示：
```
X = FFT(x, formula="direct")
```

### 8. 调试与可视化语法

#### 中间结果输出
```
FFT_DEBUG(input) {
    show_bitreverse = true
    show_twiddles = true
    show_stages = [1, 2, 3]
    save_graph = "fft_flow.png"
}
```

#### 性能分析
```
PROFILE_FFT(N) {
    method = "radix2"
    memory_analysis = true
    operation_count = true
    output_csv = "fft_profile.csv"
}
```

## 语法特色

1. **数学友好**: 语法设计尽可能接近数学公式
2. **操作符重载**: 使用熟悉的数学符号表示复杂操作
3. **类型安全**: 复数运算的类型检查
4. **可读性强**: 代码即文档，易于理解和维护
5. **可扩展**: 支持不同FFT变体的语法扩展

## 错误处理

#### 语法错误示例
```
# 错误：N不是2的幂
FFT([1,2,3], N=3)

# 错误：复数格式不正确
let z = 1 + 2i  # 正确
let z = 1 + 2j  # 错误（使用i表示虚部）
```

#### 运行时检查
```
assert_power_of_two(N)
assert_sequence_length(input, N)
```

## 与底层实现映射

| DSL语法 | 底层操作 |
|---------|----------|
| `FFT(sequence)` | 调用radix2_fft函数 |
| `a ⊕ b` | 生成蝶形加法指令 |
| `W_N^k` | 加载预计算的旋转因子 |
| `butterfly()` | 生成蝶形运算代码块 |

## 示例：从数学到DSL

**数学公式:**
```
X[k] = G[k] + W_N^k·H[k]
X[k+N/2] = G[k] - W_N^k·H[k]
```

**DSL表达式:**
```
let (X_k, X_kN) = butterfly(G[k], H[k], W_N^k)
```

**生成的中间代码:**
```
temp = W_N^k * H[k]
X[k] = G[k] + temp
X[k + N/2] = G[k] - temp
```