
(* The type of tokens. *)

type token = 
  | WHILE
  | UNIT
  | TYPE
  | TRUE
  | TO
  | THEN
  | STAR
  | SEMICOLON
  | RPAR
  | REC
  | RBRACKET
  | RARROW
  | POINT
  | PLUS
  | OR
  | NOT
  | MUTABLE
  | MOD
  | MINUS
  | LPAR
  | LET
  | LBRACKET
  | LARROW
  | INT
  | INF_OR_EQ
  | INF
  | IN
  | IF
  | IDENT of (string)
  | FUN
  | FOR
  | FALSE
  | EQUAL
  | EOF
  | ELSE
  | DONE
  | DO
  | DIV
  | DIFF
  | CST of (int)
  | COLON
  | BOOL_EQUAL
  | BOOL
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Mml.prog)
