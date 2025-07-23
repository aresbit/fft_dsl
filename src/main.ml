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
    flush_all ();
    
    (* 读取输入文件 *)
    let content = read_file input_file in
    Printf.printf "DSL content:\n%s\n---\n" content;
    flush_all ();
    
    (* 词法和语法分析 *)
    let lexbuf = Lexing.from_string content in
    Lexing.set_filename lexbuf input_file;
    
    (* 改进的错误处理 *)
    let ast = 
      try 
        let result = Parser.program Lexer.token lexbuf in
        Printf.printf "✓ Parsing successful\n";
        flush_all ();
        result
      with 
      | Parsing.Parse_error ->
        let pos = Lexing.lexeme_start_p lexbuf in
        let line = pos.pos_lnum in
        let col = pos.pos_cnum - pos.pos_bol in
        let token = Lexing.lexeme lexbuf in
        Printf.eprintf "✗ Parse error at line %d, column %d\n" line col;
        Printf.eprintf "   Near token: '%s'\n" token;
        flush_all ();
        raise Parsing.Parse_error
      | Lexer.Error msg ->
        Printf.eprintf "✗ Lexical error: %s\n" msg;
        flush_all ();
        raise (Lexer.Error msg)
      | exn ->
        Printf.eprintf "✗ Unexpected parsing error: %s\n" (Printexc.to_string exn);
        flush_all ();
        raise exn
    in
    
    Printf.printf "✓ Successfully parsed %d FFT definitions\n" (List.length ast);
    flush_all ();
    
    (* 语义分析 *)
    let validated_ast = 
      try
        let result = Semantic.analyze_program ast in
        Printf.printf "✓ Semantic analysis completed\n";
        flush_all ();
        result
      with Semantic.SemanticError msg ->
        Printf.eprintf "✗ Semantic error: %s\n" msg;
        flush_all ();
        raise (Semantic.SemanticError msg)
    in
    
    (* 代码生成 *)
    let ocaml_code = Codegen.generate_ocaml_program validated_ast in
    let ocaml_file = 
      try Filename.chop_extension output_file ^ ".ml"
      with Invalid_argument _ -> output_file ^ ".ml" in
    
    (* 写入OCaml文件 *)
    let oc = open_out ocaml_file in
    output_string oc ocaml_code;
    close_out oc;
    Printf.printf "✓ Generated OCaml code: %s\n" ocaml_file;
    flush_all ();
    
    (* 编译OCaml代码 *)
    let compile_cmd = Printf.sprintf "ocamlc -o %s %s" output_file ocaml_file in
    Printf.printf "Compiling: %s\n" compile_cmd;
    flush_all ();
    let status = Sys.command compile_cmd in
    
    if status = 0 then (
      Printf.printf "✓ Successfully compiled to: %s\n" output_file;
      flush_all ()
    ) else (
      Printf.eprintf "✗ OCaml compilation failed with status %d\n" status;
      flush_all ();
      Printf.printf "Generated OCaml code content:\n";
      Printf.printf "=== %s ===\n" ocaml_file;
      let debug_content = read_file ocaml_file in
      Printf.printf "%s\n" debug_content;
      Printf.printf "=== End of %s ===\n" ocaml_file
    )
    
  with
  | Sys_error msg -> 
      Printf.eprintf "✗ File error: %s\n" msg;
      flush_all ()
  | Parsing.Parse_error -> 
      Printf.eprintf "✗ Parse error - check your DSL syntax\n";
      flush_all ()
  | Semantic.SemanticError msg -> 
      Printf.eprintf "✗ Semantic error: %s\n" msg;
      flush_all ()
  | exn -> 
      Printf.eprintf "✗ Unexpected error: %s\n" (Printexc.to_string exn);
      flush_all ()

let () =
  if Array.length Sys.argv < 2 then begin
    Printf.eprintf "Usage: %s <fft_dsl_file> [output_executable]\n" Sys.argv.(0);
    Printf.eprintf "\nExample:\n";
    Printf.eprintf "  %s examples/my_fft.fft my_fft_program\n" Sys.argv.(0);
    exit 1
  end;
  
  let input_file = Sys.argv.(1) in
  let output_file = 
    if Array.length Sys.argv > 2 then Sys.argv.(2)
    else begin
      try (Filename.chop_extension input_file) ^ "_fft"
      with Invalid_argument _ -> input_file ^ "_fft"
    end
  in
  
  Printf.printf "FFT DSL Compiler v1.0\n";
  Printf.printf "Input:  %s\n" input_file;
  Printf.printf "Output: %s\n" output_file;
  Printf.printf "\n";
  flush_all ();
  
  compile_file input_file output_file