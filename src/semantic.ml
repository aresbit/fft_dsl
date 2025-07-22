(* FFT DSL 语义分析 *)

open Ast

exception SemanticError of string

(* 检查FFT大小是否为2的幂 *)
let is_power_of_two n =
  n > 0 && (n land (n - 1)) = 0

(* 验证FFT定义的语义正确性 *)
let validate_fft_def (fft_def : fft_def) =
  if not (is_power_of_two fft_def.size) then
    raise (SemanticError (Printf.sprintf "FFT size %d must be a power of 2" fft_def.size));
  
  (* 这里可以添加更多语义检查，比如：
     - 变量使用前是否已定义
     - 数组索引是否越界
     - 旋转因子参数是否合法 *)
  fft_def

(* 语义分析主函数 *)
let analyze_program (prog : program) =
  List.map validate_fft_def prog