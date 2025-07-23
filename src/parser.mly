%{
  open Ast
%}

%token FFT SIZE BASE_CASE WHEN RECURSIVE FOR TO DO IF THEN ELSE END TWIDDLE_W DONE
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
%right POWER IMAGINARY
%left UNDERSCORE

%%

program:
  | fft_definitions EOF { $1 }

fft_definitions:
  | { [] }
  | fft_definitions fft_definition { $2 :: $1 }
  | fft_definitions NEWLINE { $1 }
  | fft_definition { [$1] }

fft_definition:
  | FFT ID SIZE INT LBRACE base_case_section recursive_section RBRACE
    { { name = $2; size = $4; base_case = $6; recursive_case = $7 } }

base_case_section:
  | BASE_CASE WHEN SIZE EQUAL INT LBRACE statement_list RBRACE { List.rev $7 }

recursive_section:
  | RECURSIVE LBRACE statement_list RBRACE { List.rev $3 }

statement_list:
  | { [] }
  | statement_list NEWLINE { $1 }
  | statement_list statement { $2 :: $1 }
  | statement_list statement NEWLINE { $2 :: $1 }

statement:
  | ID EQUAL complex_expr { Assign ($1, $3) }
  | ID LBRACKET INT RBRACKET EQUAL complex_expr { ArrayAssign ($1, $3, $6) }
  | FOR ID EQUAL INT TO INT DO statement_list DONE
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
  | TWIDDLE_W UNDERSCORE INT POWER complex_expr { Twiddle ($3, $5) }
  | LPAREN complex_expr RPAREN { $2 }

%%