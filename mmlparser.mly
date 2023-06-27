%{

 open Lexing
 open Mml
 exception Ident_missing of string 
 let ident_missing s = raise (Ident_missing s)

%}

%token PLUS STAR EQUAL MINUS DIV BOOL_EQUAL DIFF INF INF_OR_EQ AND OR LPAR RPAR LBRACKET RBRACKET SEMICOLON COLON POINT LARROW RARROW 
%token TRUE FALSE FUN LET REC IN IF THEN ELSE MOD NOT TYPE INT BOOL UNIT MUTABLE FOR TO DO WHILE DONE
%token <int> CST
%token <string> IDENT
%token EOF


%left IN

%right SEMICOLON


%nonassoc THEN
%nonassoc ELSE



%right LARROW
%left RARROW



%right OR

%right AND

%left BOOL_EQUAL
%left DIFF
%left INF
%left INF_OR_EQ



%left MINUS
%left PLUS

%left STAR
%left DIV
%left MOD


%left IDENT

%nonassoc CST
%nonassoc LPAR
%nonassoc LBRACKET

%nonassoc TRUE
%nonassoc FALSE




%start program
%type <Mml.prog> program

%%

program:
| l=list( tdef = typ_def {tdef}) e=expression EOF { {types=l ; code=e}}
;

typ_entry:
| m=option(MUTABLE) x=IDENT COLON t=typ SEMICOLON {match m with 
 |None -> (x,t,false)
 |_ -> (x,t,true)
 }
;

typ_def:
| TYPE x=IDENT EQUAL LBRACKET l=nonempty_list(typ_entry) RBRACKET {x,l}
;


typ:
| n=INT {TInt}
| b=BOOL {TBool}
| u=UNIT {TUnit}
| x=IDENT {TStrct(x)}
| t1=typ RARROW t2=typ {TFun(t1,t2)}
| LPAR t=typ RPAR {t}
;


simple_expression:
| n=CST { Int(n) }
| x=IDENT { Var(x)}
| TRUE {Bool(true)}
| FALSE {Bool(false)}
| LPAR RPAR {Unit}
| e=simple_expression POINT x=IDENT {GetF(e,x)}
| LBRACKET l = nonempty_list(x=IDENT ; EQUAL ; e=expression ; SEMICOLON {x,e} ) RBRACKET {Strct(l)}
| LPAR e=expression RPAR {e}

;

expression:
| e=simple_expression { e }
| op=uniop e=simple_expression {Uop(op,e)}
| e1=expression op=binop e2=expression { Bop(op, e1, e2) }
| e1=expression e2=simple_expression {App(e1,e2)}
| IF e1=expression THEN e2=expression { If(e1,e2,Unit) }
| IF e1=expression THEN e2=expression ELSE e3=expression { If(e1,e2,e3)}
| FUN LPAR x=IDENT COLON t=typ RPAR RARROW e=expression {Fun(x,t,e)}
| LET f=IDENT args=list(LPAR ; x=IDENT ; COLON ; t=typ ; RPAR {x,t} ) EQUAL e1=expression IN e2=expression { let fn = mk_fun args e1 in Let(f,fn,e2)}
(*| LET error { ident_missing "il manque l'ident " }*)
| LET REC f=IDENT args=list(LPAR ; x=IDENT ;COLON; t=typ; RPAR {x,t}) 
COLON t=typ EQUAL e1=expression IN e2=expression 
{let fn = mk_fun_type args t in let fm = mk_fun args e1 in Let(f,Fix(f,fn,fm),e2)}
| e=simple_expression POINT x=IDENT LARROW e1=expression {SetF(e,x,e1)}
| e1 = expression SEMICOLON e2=expression {Seq(e1,e2)}
| FOR x=IDENT EQUAL e1=expression TO e2=expression DO e3=expression DONE {For(x,e1,e2,e3)}
| WHILE e1=expression DO e2=expression DONE {While(e1,e2)}
;

%inline binop:
| PLUS { Add }
| STAR { Mul }
| MINUS { Sub }
| DIV {Div}
| MOD {Mod}
| BOOL_EQUAL {Eq}
| DIFF {Neq}
| INF {Lt}
| INF_OR_EQ {Le}
| AND { And }
| OR { Or }

%inline uniop:
| MINUS { Neg}
| NOT { Not}

;

