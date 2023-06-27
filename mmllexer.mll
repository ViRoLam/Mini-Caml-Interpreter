{

  open Lexing
  open Mmlparser

  exception Lexing_error of string   

  let keyword_or_ident =
    let h = Hashtbl.create 22 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ "true" , TRUE ;
      "false" , FALSE ;
      "fun" , FUN ;
      "let" , LET ; 
      "rec" , REC ;
      "in" , IN;
      "if", IF;
      "then", THEN;
      "else", ELSE;
      "mod", MOD;
      "not", NOT;
      "type", TYPE;
      "int", INT;
      "bool", BOOL;
      "unit", UNIT;
      "mutable",MUTABLE ;
      "for", FOR ;
      "to", TO ;
      "do", DO ;
      "done", DONE ;
      "while", WHILE ;] ;
    fun s ->
      try  Hashtbl.find h s
      with Not_found -> IDENT(s)
        
}

let digit = ['0'-'9']
let number = digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*
  
rule token = parse      
  | ['\n']   { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+ { token lexbuf }
  | "(*"   { comment lexbuf; token lexbuf }
  | number as n   { CST(int_of_string n) }
  | ident as id {keyword_or_ident id}
  | "+" { PLUS }
  | "*" { STAR }
  | "=" {EQUAL}
  | "-" {MINUS}
  | "/" {DIV}
  | "==" {BOOL_EQUAL}
  | "!=" {DIFF}
  | "<" {INF}
  | "<=" {INF_OR_EQ}
  | "&&" {AND}
  | "||" {OR}
  | "(" {LPAR}
  | ")" {RPAR}
  | "{" {LBRACKET}
  | "}" {RBRACKET}
  | ";" {SEMICOLON}
  | ":" {COLON}
  | "." {POINT}
  | "<-" {LARROW}
  | "->" {RARROW}
  | _ { raise (Lexing_error ("unknown character : " ^ (lexeme lexbuf))) }
  | eof { EOF }

and comment = parse
  | "*)"
      { () }
  | "(*"
      { comment lexbuf; comment lexbuf }
  | _
      { comment lexbuf }
  | eof
      { raise (Lexing_error "unterminated comment") }
