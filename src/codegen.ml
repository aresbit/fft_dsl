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

let print_complex c = Printf.printf "%g + %gi" c.re c.im
|}

(* 生成复数表达式的OCaml代码 *)
let rec generate_complex_expr ~temp_vars = function
  | ComplexLit (r, i) -> Printf.sprintf "{ re = %.6f; im = %.6f }" r i
  | ComplexVar s -> 
      if List.mem s temp_vars then "!" ^ s else s
  | ComplexArray (arr, idx) -> Printf.sprintf "%s.(%d)" arr idx
  | Add (e1, e2) -> 
      Printf.sprintf "(add_complex (%s) (%s))" 
        (generate_complex_expr ~temp_vars e1) (generate_complex_expr ~temp_vars e2)
  | Sub (e1, e2) ->
      Printf.sprintf "(sub_complex (%s) (%s))"
        (generate_complex_expr ~temp_vars e1) (generate_complex_expr ~temp_vars e2)
  | Mul (e1, e2) ->
      Printf.sprintf "(mul_complex (%s) (%s))"
        (generate_complex_expr ~temp_vars e1) (generate_complex_expr ~temp_vars e2)
  | Twiddle (n, k) ->
      let k_expr = match k with
        | ComplexLit (r, _) -> string_of_int (int_of_float r)
        | ComplexVar s -> 
            if List.mem s temp_vars then "!" ^ s else s
        | _ -> Printf.sprintf "(int_of_float (%s).re)" (generate_complex_expr ~temp_vars k)
      in
      Printf.sprintf "(twiddle_factor %d (%s))" n k_expr

(* 生成语句的OCaml代码 *)
let rec generate_statement ~temp_vars = function
  | Assign (var, expr) ->
      Printf.sprintf "    let %s = %s in" var (generate_complex_expr ~temp_vars expr)
  | ArrayAssign (arr, idx, expr) ->
      Printf.sprintf "    %s.(%d) <- %s;" arr idx (generate_complex_expr ~temp_vars expr)
  | For (var, start, end_val, stmts) ->
      let body = String.concat "\n" (List.map (generate_statement ~temp_vars) stmts) in
      Printf.sprintf "    for %s = %d to %d do\n%s\n    done;" var start end_val body
  | If (var, value, then_stmts, else_stmts) ->
      let then_body = String.concat "\n" (List.map (generate_statement ~temp_vars) then_stmts) in
      let else_part = match else_stmts with
        | None -> ""
        | Some stmts -> 
            let else_body = String.concat "\n" (List.map (generate_statement ~temp_vars) stmts) in
            Printf.sprintf " else (\n%s\n    )" else_body
      in
      Printf.sprintf "    if %s = %d then (\n%s\n    )%s;" var value then_body else_part

(* 生成FFT函数 *)
let generate_fft_function (fft_def : fft_def) =
  let recursive_statements = fft_def.recursive_case in
  let collect_temp_vars stmts =
    List.fold_left (fun acc stmt ->
      match stmt with
      | Assign (var, _) when var <> "output" -> var :: acc
      | _ -> acc
    ) [] stmts
  in
  
  let temp_vars = collect_temp_vars recursive_statements in
  let temp_var_decls = String.concat "\n" (List.map (fun var ->
    Printf.sprintf "    let %s = ref complex_zero in" var
  ) temp_vars) in
  
  let generate_stmt_with_refs stmt =
    match stmt with
    | Assign (var, expr) ->
        Printf.sprintf "    %s := %s;" var (generate_complex_expr ~temp_vars expr)
    | ArrayAssign (arr, idx, expr) ->
        Printf.sprintf "    %s.(%d) <- %s;" arr idx (generate_complex_expr ~temp_vars expr)
    | _ -> generate_statement ~temp_vars stmt
  in
  
  let recursive_body = String.concat "\n" (List.map generate_stmt_with_refs recursive_statements) in
  let base_case_body = String.concat "\n" (List.map (generate_statement ~temp_vars) fft_def.base_case) in
  
  Printf.sprintf {|
let %s input =
  let n = Array.length input in
  let output = Array.copy input in
  
  if n = 1 then (
%s
    output
  ) else (
    (* 初始化临时变量 *)
%s
    
    (* 执行用户定义的逻辑 *)
%s
    
    output
  )
|} fft_def.name base_case_body temp_var_decls recursive_body

(* 生成完整的OCaml程序 *)
let generate_ocaml_program (prog : program) =
  let complex_type = generate_complex_type () in
  let functions = String.concat "\n\n" (List.map generate_fft_function prog) in
  let main_function = 
    match prog with
    | [] -> ""
    | first_fft :: _ ->
        let first_name = first_fft.name in
        Printf.sprintf {|
let () =
  if Array.length Sys.argv < 2 then begin
    Printf.printf "Usage: %%s [real1 imag1 real2 imag2 ...]\\n" Sys.argv.(0);
    exit 1
  end;
  
  let args = Array.sub Sys.argv 1 (Array.length Sys.argv - 1) in
  
  let input = Array.init (Array.length args / 2) (fun i ->
    let real = float_of_string args.(2 * i) in
    let imag = float_of_string args.(2 * i + 1) in
    { re = real; im = imag }
  ) in
  
  Printf.printf "Input:\\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%%d]: %%g %%c %%gi\\n" i c.re (if c.im >= 0.0 then '+' else '-') (abs_float c.im)
  ) input;
  
  let result = %s input in
  
  Printf.printf "\\nFFT Result:\\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%%d]: %%g %%c %%gi\\n" i c.re (if c.im >= 0.0 then '+' else '-') (abs_float c.im)
  ) result
|} first_name
  in
  
  String.concat "\n" [complex_type; functions; main_function]