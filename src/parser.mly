%{
  open Ast
%}

%token FFT SIZE BASE_CASE WHEN RECURSIVE FOR TO DO IF THEN ELSE END DONE
%token EQUAL PLUS MINUS MULT LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token POWER UNDERSCORE COMMA IMAGINARY EQ EOF
%token <int> INT
%token <float> FLOAT  
%token <string> ID

%left PLUS MINUS
%left MULT
%right POWER

%start program
%type <Ast.program> program

%%

program:
  | fft_definitions EOF { List.rev $1 }

fft_definitions:
  | /* empty */ { [] }
  | fft_definitions fft_definition { $2 :: $1 }

fft_definition:
  | FFT ID SIZE INT LBRACE base_case_section recursive_section RBRACE
    { { name = $2; size = $4; base_case = $6; recursive_case = $7 } }

base_case_section:
  | BASE_CASE WHEN SIZE EQUAL INT LBRACE statement_list RBRACE 
    { List.rev $7 }

recursive_section:
  | RECURSIVE LBRACE statement_list RBRACE 
    { List.rev $3 }

statement_list:
  | /* empty */ { [] }
  | statement_list statement { $2 :: $1 }

statement:
  | ID EQUAL complex_expr 
    { Assign ($1, $3) }
  | ID LBRACKET INT RBRACKET EQUAL complex_expr 
    { ArrayAssign ($1, $3, $6) }
  | FOR ID EQUAL INT TO INT DO statement_list DONE
    { For ($2, $4, $6, List.rev $8) }
  | IF SIZE EQ INT THEN LBRACE statement_list RBRACE
    { If ("size", $4, List.rev $7, None) }
  | IF SIZE EQ INT THEN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE
    { If ("size", $4, List.rev $7, Some (List.rev $11)) }

complex_expr:
  | complex_expr PLUS complex_expr { Add ($1, $3) }
  | complex_expr MINUS complex_expr { Sub ($1, $3) }
  | MULT complex_expr complex_expr { Mul ($2, $3) }
  | primary_expr { $1 }

primary_expr:
  | twiddle_expr { $1 }
  | number_expr { $1 }
  | ID LBRACKET INT RBRACKET { ComplexArray ($1, $3) }
  | ID { ComplexVar $1 }
  | LPAREN complex_expr RPAREN { $2 }

twiddle_expr:
  | ID POWER INT 
    { 
      let id_str = $1 in
      if String.length id_str >= 2 && String.sub id_str 0 2 = "W_" then (
        let n_str = String.sub id_str 2 (String.length id_str - 2) in
        let n = int_of_string n_str in
        Twiddle (n, ComplexLit (float_of_int $3, 0.0))
      ) else (
        ComplexVar id_str
      )
    }
  | ID POWER ID
    {
      let id_str = $1 in
      if String.length id_str >= 2 && String.sub id_str 0 2 = "W_" then (
        let n_str = String.sub id_str 2 (String.length id_str - 2) in
        let n = int_of_string n_str in
        Twiddle (n, ComplexVar $3)
      ) else (
        ComplexVar id_str
      )
    }

number_expr:
  | FLOAT { ComplexLit ($1, 0.0) }
  | INT { ComplexLit (float_of_int $1, 0.0) }
  | FLOAT PLUS FLOAT MULT IMAGINARY { ComplexLit ($1, $3) }
  | FLOAT MINUS FLOAT MULT IMAGINARY { ComplexLit ($1, -.$3) }
  | FLOAT MULT IMAGINARY { ComplexLit (0.0, $1) }
  | INT MULT IMAGINARY { ComplexLit (0.0, float_of_int $1) }
  | IMAGINARY { ComplexLit (0.0, 1.0) }

%%