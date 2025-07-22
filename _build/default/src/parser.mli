type token =
  | FFT
  | SIZE
  | BASE_CASE
  | WHEN
  | RECURSIVE
  | FOR
  | TO
  | IF
  | THEN
  | ELSE
  | END
  | TWIDDLE_W
  | EQUAL
  | PLUS
  | MINUS
  | MULT
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | LBRACE
  | RBRACE
  | POWER
  | UNDERSCORE
  | COMMA
  | IMAGINARY
  | NEWLINE
  | EQ
  | EOF
  | INT of (
# 8 "src/parser.mly"
        int
# 35 "src/parser.mli"
)
  | FLOAT of (
# 9 "src/parser.mly"
        float
# 40 "src/parser.mli"
)
  | ID of (
# 10 "src/parser.mly"
        string
# 45 "src/parser.mli"
)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
