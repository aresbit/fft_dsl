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