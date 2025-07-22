(* =================== src/ast.ml =================== *)
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

(* =================== src/lexer.mll =================== *)
{
  open Parser
  open Lexing

  let incr_line lexbuf = 
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with 
      pos_lnum = pos.pos_lnum + 1;
      pos_bol = pos.pos_cnum;
    }
}

let blank = [' ' '\t' '\r']
let newline = '\n' | "\r\n"
let comment = "//" [^ '\n' '\r']*

let digit = ['0'-'9']
let integer = '-'? digit+
let float_num = '-'? digit+ ('.' digit+)?
let identifier = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '_' '0'-'9']*

rule token = parse
  | blank+ { token lexbuf }
  | newline { incr_line lexbuf; NEWLINE }
  | comment { token lexbuf }
  
  (* 关键字 *)
  | "fft" { FFT }
  | "size" { SIZE }
  | "base_case" { BASE_CASE }
  | "when" { WHEN }
  | "recursive" { RECURSIVE }
  | "for" { FOR }
  | "to" { TO }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "end" { END }
  | "W" { TWIDDLE_W }
  
  (* 操作符和分隔符 *)
  | "=" { EQUAL }
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { MULT }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "[" { LBRACKET }
  | "]" { RBRACKET }
  | "{" { LBRACE }
  | "}" { RBRACE }
  | "^" { POWER }
  | "_" { UNDERSCORE }
  | "," { COMMA }
  | "i" { IMAGINARY }
  | "==" { EQ }
  
  (* 字面量 *)
  | integer { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float_num { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | identifier { ID (Lexing.lexeme lexbuf) }
  
  | eof { EOF }

(* =================== src/parser.mly =================== *)
%{
  open Ast
%}

%token FFT SIZE BASE_CASE WHEN RECURSIVE FOR TO IF THEN ELSE END TWIDDLE_W
%token EQUAL PLUS MINUS MULT LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token POWER UNDERSCORE COMMA IMAGINARY NEWLINE EQ EOF
%token <int> INT
%token <float> FLOAT  
%token <string> ID

%start program
%type <Ast.program> program

%right EQUAL
%left PLUS MINUS
%left MULT
%right POWER

%%

program:
  | fft_definitions EOF { List.rev $1 }

fft_definitions:
  | { [] }
  | fft_definitions fft_definition { $2 :: $1 }
  | fft_definitions NEWLINE { $1 }

fft_definition:
  | FFT ID SIZE INT LBRACE fft_body RBRACE
    { { name = $2; size = $4; base_case = fst $6; recursive_case = snd $6 } }

fft_body:
  | base_case_section recursive_section { ($1, $2) }

base_case_section:
  | BASE_CASE WHEN SIZE EQ INT LBRACE statement_list RBRACE { $7 }

recursive_section:
  | RECURSIVE LBRACE statement_list RBRACE { $3 }

statement_list:
  | { [] }
  | statement_list statement { $2 :: $1 }
  | statement_list NEWLINE { $1 }

statement:
  | ID EQUAL complex_expr { Assign ($1, $3) }
  | ID LBRACKET INT RBRACKET EQUAL complex_expr { ArrayAssign ($1, $3, $6) }
  | FOR ID EQUAL INT TO INT LBRACE statement_list RBRACE 
    { For ($2, $4, $6, List.rev $8) }
  | IF SIZE EQ INT THEN LBRACE statement_list RBRACE
    { If ("size", $4, List.rev $7, None) }
  | IF SIZE EQ INT THEN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE
    { If ("size", $4, List.rev $7, Some (List.rev $11)) }

complex_expr:
  | FLOAT { ComplexLit ($1, 0.0) }
  | FLOAT PLUS FLOAT MULT IMAGINARY { ComplexLit ($1, $3) }
  | FLOAT MULT IMAGINARY { ComplexLit (0.0, $1) }
  | ID { ComplexVar $1 }
  | ID LBRACKET INT RBRACKET { ComplexArray ($1, $3) }
  | complex_expr PLUS complex_expr { Add ($1, $3) }
  | complex_expr MINUS complex_expr { Sub ($1, $3) }
  | complex_expr MULT complex_expr { Mul ($1, $3) }
  | TWIDDLE_W UNDERSCORE INT POWER INT { Twiddle ($3, $5) }
  | LPAREN complex_expr RPAREN { $2 }

(* =================== src/semantic.ml =================== *)
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

(* =================== src/codegen.ml =================== *)
(* FFT DSL 代码生成 - 生成OCaml代码 *)

open Ast

(* 生成复数类型定义 *)
let generate_complex_type () =
  {|
type complex = { re: float; im: float }

let complex_zero = { re = 0.0; im = 0.0 }
let complex_one = { re = 1.0; im = 0.0 }

let add_complex c1 c2 = { re = c1.re +. c2.re; im = c1.im +. c2.im }
let sub_complex c1 c2 = { re = c1.re -. c2.re; im = c1.im -. c2.im }
let mul_complex c1 c2 = 
  { re = c1.re *. c2.re -. c1.im *. c2.im;
    im = c1.re *. c2.im +. c1.im *. c2.re }

let twiddle_factor n k =
  let angle = -2.0 *. Float.pi *. (float_of_int k) /. (float_of_int n) in
  { re = cos angle; im = sin angle }
|}

(* 生成复数表达式的OCaml代码 *)
let rec generate_complex_expr = function
  | ComplexLit (r, i) -> Printf.sprintf "{ re = %g; im = %g }" r i
  | ComplexVar s -> s
  | ComplexArray (arr, idx) -> Printf.sprintf "%s.(%d)" arr idx
  | Add (e1, e2) -> 
      Printf.sprintf "add_complex (%s) (%s)" 
        (generate_complex_expr e1) (generate_complex_expr e2)
  | Sub (e1, e2) ->
      Printf.sprintf "sub_complex (%s) (%s)"
        (generate_complex_expr e1) (generate_complex_expr e2)
  | Mul (e1, e2) ->
      Printf.sprintf "mul_complex (%s) (%s)"
        (generate_complex_expr e1) (generate_complex_expr e2)
  | Twiddle (n, k) ->
      Printf.sprintf "twiddle_factor %d %d" n k

(* 生成语句的OCaml代码 *)
let rec generate_statement = function
  | Assign (var, expr) ->
      Printf.sprintf "  let %s = %s in" var (generate_complex_expr expr)
  | ArrayAssign (arr, idx, expr) ->
      Printf.sprintf "  %s.(%d) <- %s;" arr idx (generate_complex_expr expr)
  | For (var, start, end_val, stmts) ->
      let body = String.concat "\n" (List.map generate_statement stmts) in
      Printf.sprintf "  for %s = %d to %d do\n%s\n  done;" var start end_val body
  | If (var, value, then_stmts, else_stmts) ->
      let then_body = String.concat "\n" (List.map generate_statement then_stmts) in
      let else_body = match else_stmts with
        | None -> ""
        | Some stmts -> " else begin\n" ^ String.concat "\n" (List.map generate_statement stmts) ^ "\n  end"
      in
      Printf.sprintf "  if %s = %d then begin\n%s\n  end%s;" var value then_body else_body

(* 生成FFT函数 *)
let generate_fft_function (fft_def : fft_def) =
  let base_case_code = String.concat "\n" (List.map generate_statement fft_def.base_case) in
  let recursive_code = String.concat "\n" (List.map generate_statement fft_def.recursive_case) in
  
  Printf.sprintf {|
let rec %s input =
  let n = Array.length input in
  let output = Array.copy input in
  
  (* Base case *)
  if n = 1 then (
%s
    output
  ) else (
    (* Recursive case - Radix-2 Cooley-Tukey *)
    let half_n = n / 2 in
    let even = Array.init half_n (fun i -> input.(2 * i)) in
    let odd = Array.init half_n (fun i -> input.(2 * i + 1)) in
    
    let fft_even = %s even in
    let fft_odd = %s odd in
    
    (* Combine results *)
    for k = 0 to half_n - 1 do
      let w = twiddle_factor n k in
      let t = mul_complex w fft_odd.(k) in
      output.(k) <- add_complex fft_even.(k) t;
      output.(k + half_n) <- sub_complex fft_even.(k) t;
    done;
    
%s
    output
  )
|} fft_def.name base_case_code fft_def.name fft_def.name recursive_code

(* 生成完整的OCaml程序 *)
let generate_ocaml_program (prog : program) =
  let complex_type = generate_complex_type () in
  let functions = String.concat "\n\n" (List.map generate_fft_function prog) in
  let main_function = {|
let () =
  (* 示例使用 *)
  let test_input = [|
    { re = 1.0; im = 0.0 };
    { re = 0.0; im = 0.0 };
    { re = 1.0; im = 0.0 };
    { re = 0.0; im = 0.0 };
  |] in
  
  Printf.printf "Input:\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g + %gi\n" i c.re c.im
  ) test_input;
  
  let result = fft_radix2 test_input in
  
  Printf.printf "\nFFT Result:\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g + %gi\n" i c.re c.im
  ) result
|} in
  
  String.concat "\n\n" [complex_type; functions; main_function]

(* =================== src/main.ml =================== *)
(* FFT DSL 编译器主程序 *)

let read_file filename =
  let ic = open_in filename in
  let len = in_channel_length ic in
  let buf = Bytes.create len in
  really_input ic buf 0 len;
  close_in ic;
  Bytes.to_string buf

let compile_file input_file output_file =
  try
    Printf.printf "Compiling FFT DSL: %s -> %s\n" input_file output_file;
    
    (* 读取输入文件 *)
    let content = read_file input_file in
    Printf.printf "DSL content:\n%s\n---\n" content;
    
    (* 词法和语法分析 *)
    let lexbuf = Lexing.from_string content in
    Lexing.set_filename lexbuf input_file;
    let ast = Parser.program Lexer.token lexbuf in
    Printf.printf "Successfully parsed %d FFT definitions\n" (List.length ast);
    
    (* 语义分析 *)
    let validated_ast = Semantic.analyze_program ast in
    Printf.printf "Semantic analysis completed\n";
    
    (* 代码生成 *)
    let ocaml_code = Codegen.generate_ocaml_program validated_ast in
    let ocaml_file = 
      try Filename.chop_extension output_file ^ ".ml"
      with Invalid_argument _ -> output_file ^ ".ml" in
    
    (* 写入OCaml文件 *)
    let oc = open_out ocaml_file in
    output_string oc ocaml_code;
    close_out oc;
    Printf.printf "Generated OCaml code: %s\n" ocaml_file;
    
    (* 编译OCaml代码 *)
    let compile_cmd = Printf.sprintf "ocamlc -o %s %s" output_file ocaml_file in
    Printf.printf "Compiling: %s\n" compile_cmd;
    let status = Sys.command compile_cmd in
    
    if status = 0 then
      Printf.printf "Successfully compiled to: %s\n" output_file
    else
      Printf.eprintf "OCaml compilation failed\n"
    
  with
  | Sys_error msg -> Printf.eprintf "File error: %s\n" msg
  | Parsing.Parse_error -> Printf.eprintf "Parse error\n"
  | Semantic.SemanticError msg -> Printf.eprintf "Semantic error: %s\n" msg
  | exn -> Printf.eprintf "Error: %s\n" (Printexc.to_string exn)

let () =
  if Array.length Sys.argv < 2 then begin
    Printf.eprintf "Usage: %s <fft_dsl_file> [output_executable]\n" Sys.argv.(0);
    exit 1
  end;
  
  let input_file = Sys.argv.(1) in
  let output_file = 
    if Array.length Sys.argv > 2 then Sys.argv.(2)
    else (Filename.chop_extension input_file) ^ "_fft"
  in
  
  compile_file input_file output_file

(* =================== dune-project =================== *)
(lang dune 3.0)

(* =================== src/dune =================== *)
(executable
 (public_name fft_dsl)
 (name main)
 (modules main lexer parser ast semantic codegen))

(ocamllex lexer)
(ocamlyacc parser)