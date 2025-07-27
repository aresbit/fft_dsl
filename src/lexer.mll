{
  open Parser
  open Lexing

  exception Error of string

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
  | newline { incr_line lexbuf; token lexbuf }
  | comment { token lexbuf }
  
  (* 关键字 - 必须在标识符之前 *)
  | "fft" { FFT }
  | "size" { SIZE }
  | "base_case" { BASE_CASE }
  | "when" { WHEN }
  | "recursive" { RECURSIVE }
  | "for" { FOR }
  | "to" { TO }
  | "do" { DO }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "end" { END }
  | "W" { TWIDDLE_W }
  | "mul" { MUL }
  
  (* 操作符和分隔符 *)
  | "==" { EQ }
  | "=" { EQUAL }
  | "+" { PLUS }
  | "-" { MINUS }
  | "mul" { MULT }
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
  
  (* 旋转因子模式 W_N *)
  | "W_" (digit+ as n) { 
      let twiddle_id = "W_" ^ n in
      ID twiddle_id
    }
  
  (* 字面量和标识符 *)
  | integer { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float_num { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | identifier { ID (Lexing.lexeme lexbuf) }
  | "W_" digit+ "^" digit+ { 
      let str = Lexing.lexeme lexbuf in
      let len = String.length str in
      let underscore_pos = String.index str '_' in
      let power_pos = String.index str '^' in
      let n = int_of_string (String.sub str (underscore_pos + 1) (power_pos - underscore_pos - 1)) in
      let k = int_of_string (String.sub str (power_pos + 1) (len - power_pos - 1)) in
      Parser.TWIDDLE(n, k)
  }
  
  | eof { EOF }
  | _ { raise (Error ("Unexpected character: " ^ Lexing.lexeme lexbuf)) }