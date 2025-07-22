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
# 35 "src/parser.ml"
)
  | FLOAT of (
# 9 "src/parser.mly"
        float
# 40 "src/parser.ml"
)
  | ID of (
# 10 "src/parser.mly"
        string
# 45 "src/parser.ml"
)

open Parsing
let _ = parse_error;;
# 2 "src/parser.mly"
  open Ast
# 52 "src/parser.ml"
let yytransl_const = [|
  257 (* FFT *);
  258 (* SIZE *);
  259 (* BASE_CASE *);
  260 (* WHEN *);
  261 (* RECURSIVE *);
  262 (* FOR *);
  263 (* TO *);
  264 (* IF *);
  265 (* THEN *);
  266 (* ELSE *);
  267 (* END *);
  268 (* TWIDDLE_W *);
  269 (* EQUAL *);
  270 (* PLUS *);
  271 (* MINUS *);
  272 (* MULT *);
  273 (* LPAREN *);
  274 (* RPAREN *);
  275 (* LBRACKET *);
  276 (* RBRACKET *);
  277 (* LBRACE *);
  278 (* RBRACE *);
  279 (* POWER *);
  280 (* UNDERSCORE *);
  281 (* COMMA *);
  282 (* IMAGINARY *);
  283 (* NEWLINE *);
  284 (* EQ *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  285 (* INT *);
  286 (* FLOAT *);
  287 (* ID *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\003\000\004\000\005\000\006\000\
\006\000\006\000\007\000\007\000\007\000\007\000\007\000\008\000\
\008\000\008\000\008\000\008\000\008\000\008\000\008\000\008\000\
\008\000\000\000"

let yylen = "\002\000\
\002\000\000\000\002\000\002\000\008\000\008\000\004\000\000\000\
\002\000\002\000\003\000\006\000\009\000\008\000\012\000\001\000\
\005\000\003\000\001\000\004\000\003\000\003\000\003\000\005\000\
\003\000\002\000"

let yydefred = "\000\000\
\002\000\000\000\026\000\000\000\000\000\004\000\001\000\003\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\008\000\005\000\000\000\000\000\000\000\000\000\
\000\000\007\000\010\000\000\000\009\000\008\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\006\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\025\000\000\000\018\000\000\000\000\000\000\000\
\023\000\000\000\000\000\008\000\000\000\000\000\020\000\000\000\
\008\000\000\000\024\000\017\000\000\000\000\000\013\000\000\000\
\008\000\000\000\015\000"

let yydgoto = "\002\000\
\003\000\004\000\008\000\014\000\017\000\022\000\029\000\042\000"

let yysindex = "\002\000\
\000\000\000\000\000\000\001\000\233\254\000\000\000\000\000\000\
\011\255\241\254\000\255\021\255\026\255\031\255\037\255\023\255\
\025\255\017\255\000\000\000\000\024\255\001\255\033\255\028\255\
\061\255\000\000\000\000\248\254\000\000\000\000\056\255\042\255\
\090\255\043\255\052\255\048\255\059\255\038\255\090\255\246\254\
\062\255\120\255\058\255\000\000\086\255\076\255\066\255\112\255\
\071\255\070\255\074\255\090\255\090\255\090\255\099\255\075\255\
\093\255\094\255\000\000\100\255\000\000\103\255\109\255\109\255\
\000\000\090\255\098\255\000\000\108\255\105\255\000\000\120\255\
\000\000\060\255\000\000\000\000\067\255\122\255\000\000\117\255\
\000\000\078\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\049\255\
\004\255\084\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\019\255\034\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\091\255\
\000\000\000\000\000\000\000\000\000\000\102\255\000\000\000\000\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\226\255\000\000\219\255"

let yytablesize = 284
let yytable = "\035\000\
\007\000\048\000\001\000\049\000\033\000\050\000\024\000\009\000\
\025\000\019\000\034\000\019\000\010\000\011\000\063\000\064\000\
\065\000\019\000\019\000\019\000\012\000\019\000\026\000\013\000\
\021\000\019\000\021\000\027\000\072\000\015\000\019\000\028\000\
\021\000\021\000\019\000\016\000\021\000\074\000\018\000\022\000\
\021\000\022\000\077\000\019\000\021\000\021\000\020\000\022\000\
\022\000\021\000\082\000\022\000\023\000\030\000\016\000\022\000\
\016\000\024\000\031\000\025\000\022\000\047\000\032\000\016\000\
\022\000\024\000\016\000\025\000\036\000\037\000\016\000\043\000\
\024\000\044\000\025\000\016\000\045\000\055\000\027\000\016\000\
\051\000\078\000\028\000\024\000\057\000\025\000\027\000\046\000\
\079\000\011\000\028\000\011\000\056\000\027\000\058\000\061\000\
\012\000\028\000\012\000\083\000\060\000\038\000\062\000\067\000\
\027\000\011\000\039\000\014\000\028\000\014\000\011\000\066\000\
\012\000\068\000\011\000\070\000\069\000\012\000\073\000\040\000\
\041\000\012\000\071\000\014\000\054\000\052\000\053\000\054\000\
\014\000\059\000\076\000\080\000\014\000\052\000\053\000\054\000\
\075\000\081\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\005\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\006\000"

let yycheck = "\030\000\
\000\000\039\000\001\000\014\001\013\001\016\001\006\001\031\001\
\008\001\006\001\019\001\008\001\002\001\029\001\052\000\053\000\
\054\000\014\001\015\001\016\001\021\001\018\001\022\001\003\001\
\006\001\022\001\008\001\027\001\066\000\004\001\027\001\031\001\
\014\001\015\001\031\001\005\001\018\001\068\000\002\001\006\001\
\022\001\008\001\073\000\021\001\028\001\027\001\022\001\014\001\
\015\001\031\001\081\000\018\001\029\001\021\001\006\001\022\001\
\008\001\006\001\031\001\008\001\027\001\024\001\002\001\015\001\
\031\001\006\001\018\001\008\001\013\001\028\001\022\001\029\001\
\006\001\022\001\008\001\027\001\029\001\020\001\027\001\031\001\
\019\001\022\001\031\001\006\001\009\001\008\001\027\001\029\001\
\022\001\006\001\031\001\008\001\007\001\027\001\029\001\026\001\
\006\001\031\001\008\001\022\001\030\001\012\001\029\001\029\001\
\027\001\022\001\017\001\006\001\031\001\008\001\027\001\013\001\
\022\001\021\001\031\001\016\001\023\001\027\001\021\001\030\001\
\031\001\031\001\020\001\022\001\016\001\014\001\015\001\016\001\
\027\001\018\001\026\001\010\001\031\001\014\001\015\001\016\001\
\029\001\021\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\001\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\027\001"

let yynames_const = "\
  FFT\000\
  SIZE\000\
  BASE_CASE\000\
  WHEN\000\
  RECURSIVE\000\
  FOR\000\
  TO\000\
  IF\000\
  THEN\000\
  ELSE\000\
  END\000\
  TWIDDLE_W\000\
  EQUAL\000\
  PLUS\000\
  MINUS\000\
  MULT\000\
  LPAREN\000\
  RPAREN\000\
  LBRACKET\000\
  RBRACKET\000\
  LBRACE\000\
  RBRACE\000\
  POWER\000\
  UNDERSCORE\000\
  COMMA\000\
  IMAGINARY\000\
  NEWLINE\000\
  EQ\000\
  EOF\000\
  "

let yynames_block = "\
  INT\000\
  FLOAT\000\
  ID\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'fft_definitions) in
    Obj.repr(
# 23 "src/parser.mly"
                        ( List.rev _1 )
# 270 "src/parser.ml"
               : Ast.program))
; (fun __caml_parser_env ->
    Obj.repr(
# 26 "src/parser.mly"
    ( [] )
# 276 "src/parser.ml"
               : 'fft_definitions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'fft_definitions) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fft_definition) in
    Obj.repr(
# 27 "src/parser.mly"
                                   ( _2 :: _1 )
# 284 "src/parser.ml"
               : 'fft_definitions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'fft_definitions) in
    Obj.repr(
# 28 "src/parser.mly"
                            ( _1 )
# 291 "src/parser.ml"
               : 'fft_definitions))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : 'base_case_section) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'recursive_section) in
    Obj.repr(
# 32 "src/parser.mly"
    ( { name = _2; size = _4; base_case = _6; recursive_case = _7 } )
# 301 "src/parser.ml"
               : 'fft_definition))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 36 "src/parser.mly"
                                                            ( _7 )
# 309 "src/parser.ml"
               : 'base_case_section))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 39 "src/parser.mly"
                                           ( _3 )
# 316 "src/parser.ml"
               : 'recursive_section))
; (fun __caml_parser_env ->
    Obj.repr(
# 42 "src/parser.mly"
    ( [] )
# 322 "src/parser.ml"
               : 'statement_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'statement) in
    Obj.repr(
# 43 "src/parser.mly"
                             ( _2 :: _1 )
# 330 "src/parser.ml"
               : 'statement_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 44 "src/parser.mly"
                           ( _1 )
# 337 "src/parser.ml"
               : 'statement_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'complex_expr) in
    Obj.repr(
# 47 "src/parser.mly"
                          ( Assign (_1, _3) )
# 345 "src/parser.ml"
               : 'statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'complex_expr) in
    Obj.repr(
# 48 "src/parser.mly"
                                                ( ArrayAssign (_1, _3, _6) )
# 354 "src/parser.ml"
               : 'statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 5 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _8 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 50 "src/parser.mly"
    ( For (_2, _4, _6, List.rev _8) )
# 364 "src/parser.ml"
               : 'statement))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 4 : int) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 52 "src/parser.mly"
    ( If ("size", _4, List.rev _7, None) )
# 372 "src/parser.ml"
               : 'statement))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 8 : int) in
    let _7 = (Parsing.peek_val __caml_parser_env 5 : 'statement_list) in
    let _11 = (Parsing.peek_val __caml_parser_env 1 : 'statement_list) in
    Obj.repr(
# 54 "src/parser.mly"
    ( If ("size", _4, List.rev _7, Some (List.rev _11)) )
# 381 "src/parser.ml"
               : 'statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 57 "src/parser.mly"
          ( ComplexLit (_1, 0.0) )
# 388 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : float) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : float) in
    Obj.repr(
# 58 "src/parser.mly"
                                    ( ComplexLit (_1, _3) )
# 396 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : float) in
    Obj.repr(
# 59 "src/parser.mly"
                         ( ComplexLit (0.0, _1) )
# 403 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 60 "src/parser.mly"
       ( ComplexVar _1 )
# 410 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 61 "src/parser.mly"
                             ( ComplexArray (_1, _3) )
# 418 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'complex_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'complex_expr) in
    Obj.repr(
# 62 "src/parser.mly"
                                   ( Add (_1, _3) )
# 426 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'complex_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'complex_expr) in
    Obj.repr(
# 63 "src/parser.mly"
                                    ( Sub (_1, _3) )
# 434 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'complex_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'complex_expr) in
    Obj.repr(
# 64 "src/parser.mly"
                                   ( Mul (_1, _3) )
# 442 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 65 "src/parser.mly"
                                       ( Twiddle (_3, _5) )
# 450 "src/parser.ml"
               : 'complex_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'complex_expr) in
    Obj.repr(
# 66 "src/parser.mly"
                               ( _2 )
# 457 "src/parser.ml"
               : 'complex_expr))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.program)
