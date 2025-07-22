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