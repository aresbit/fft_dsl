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
  | ComplexLit (r, i) -> Printf.sprintf "{ re = %.6f; im = %.6f }" r i
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
      Printf.sprintf "(twiddle_factor %d %s)" n 
        (match k with
         | ComplexLit (r, _) -> string_of_int (int_of_float r)
         | ComplexVar s -> s
         | _ -> "(" ^ generate_complex_expr k ^ ".re |> int_of_float)")

(* 生成语句的OCaml代码 *)
let rec generate_statement indent = function
  | Assign (var, expr) ->
      Printf.sprintf "%slet %s = %s in" indent var (generate_complex_expr expr)
  | ArrayAssign (arr, idx, expr) ->
      Printf.sprintf "%s%s.(%d) <- %s;" indent arr idx (generate_complex_expr expr)
  | For (var, start, end_val, stmts) ->
      let body = String.concat "\n" (List.map (generate_statement (indent ^ "  ")) stmts) in
      Printf.sprintf "%sfor %s = %d to %d do\n%s\n%sdone;" indent var start end_val body indent
  | If (var, value, then_stmts, else_stmts) ->
      let then_body = String.concat "\n" (List.map (generate_statement (indent ^ "  ")) then_stmts) in
      let else_body = match else_stmts with
        | None -> ""
        | Some stmts -> 
            let else_code = String.concat "\n" (List.map (generate_statement (indent ^ "  ")) stmts) in
            Printf.sprintf " else begin\n%s\n%send" else_code indent
      in
      Printf.sprintf "%sif %s = %d then begin\n%s\n%send%s;" indent var value then_body indent else_body

(* 生成FFT函数 *)
let generate_fft_function (fft_def : fft_def) =
  let base_case_code = String.concat "\n" (List.map (generate_statement "    ") fft_def.base_case) in
  let recursive_code = String.concat "\n" (List.map (generate_statement "    ") fft_def.recursive_case) in
  
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
    
    (* User-defined recursive statements *)
%s
    output
  )
|} fft_def.name base_case_code fft_def.name fft_def.name recursive_code

(* 生成完整的OCaml程序 *)
let generate_ocaml_program (prog : program) =
  let complex_type = generate_complex_type () in
  let functions = String.concat "\n\n" (List.map generate_fft_function prog) in
  (* Use the first FFT function name for the main test *)
  let main_function = 
    match prog with
    | [] -> ""
    | first_fft :: _ ->
        let first_name = first_fft.name in
        let template = String.concat "\n" [
          "let () =";
          "  (* 示例使用 *)";
          "  let test_input = [|";
          "    { re = 1.0; im = 0.0 };";
          "    { re = 0.0; im = 0.0 };";
          "    { re = 1.0; im = 0.0 };";
          "    { re = 0.0; im = 0.0 };";
          "  |] in";
          "  ";
          "  Printf.printf \"Input:\\n\";";
          "  Array.iteri (fun i c -> ";
          "    Printf.printf \"[%d]: %g + %gi\\n\" i c.re c.im";
          "  ) test_input;";
          "  ";
          "  let result = " ^ first_name ^ " test_input in";
          "  ";
          "  Printf.printf \"\\nFFT Result:\\n\";";
          "  Array.iteri (fun i c -> ";
          "    Printf.printf \"[%d]: %g + %gi\\n\" i c.re c.im";
          "  ) result"
        ] in
        template
  in
  
  String.concat "\n\n" [complex_type; functions; main_function]