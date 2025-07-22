(* FFT DSL Abstract Syntax Tree - Radix-2 基础版本 *)

type complex_expr =
  | ComplexLit of float * float  (* 复数字面量 (real, imag) *)
  | ComplexVar of string         (* 复数变量 *)
  | ComplexArray of string * int (* 复数数组元素 arr[index] *)
  | Add of complex_expr * complex_expr
  | Sub of complex_expr * complex_expr  
  | Mul of complex_expr * complex_expr
  | Twiddle of int * int         (* 旋转因子 W_N^k *)

type stmt =
  | Assign of string * complex_expr                    (* x = expr *)
  | ArrayAssign of string * int * complex_expr         (* arr[i] = expr *)
  | For of string * int * int * stmt list             (* for i = start to end *)
  | If of string * int * stmt list * stmt list option (* if size == n then ... *)

type fft_def = {
  name: string;
  size: int;                (* FFT大小，必须是2的幂 *)
  base_case: stmt list;     (* 基础情况 (size=1) *)
  recursive_case: stmt list; (* 递归情况 *)
}

type program = fft_def list

(* 辅助函数 *)
let rec string_of_complex_expr = function
  | ComplexLit (r, i) -> Printf.sprintf "(%g + %gi)" r i
  | ComplexVar s -> s
  | ComplexArray (arr, idx) -> Printf.sprintf "%s[%d]" arr idx
  | Add (e1, e2) -> Printf.sprintf "(%s + %s)" (string_of_complex_expr e1) (string_of_complex_expr e2)
  | Sub (e1, e2) -> Printf.sprintf "(%s - %s)" (string_of_complex_expr e1) (string_of_complex_expr e2)
  | Mul (e1, e2) -> Printf.sprintf "(%s * %s)" (string_of_complex_expr e1) (string_of_complex_expr e2)
  | Twiddle (n, k) -> Printf.sprintf "W_%d^%d" n k