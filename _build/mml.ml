(* Syntaxe abstraite Mini-ML *)

type typ = 
  | TInt 
  | TBool
  | TUnit
  | TFun of typ * typ
  | TStrct of string
type strct = (string * typ * bool) list

let rec typ_to_string = function
  | TInt  -> "int"
  | TBool -> "bool"
  | TUnit -> "unit"
  | TFun(typ1, typ2) -> 
     Printf.sprintf "(%s) -> %s" (typ_to_string typ1) (typ_to_string typ2)
  | TStrct s -> s

type uop = Neg | Not
type bop = Add | Sub | Mul | Div | Mod | Eq | Neq | Lt | Le | And | Or

type expr =
  | Int   of int
  | Bool  of bool
  | Unit
  | Uop   of uop * expr
  | Bop   of bop * expr * expr
  | Var   of string
  | Let   of string * expr * expr
  | If    of expr * expr * expr
  | Fun   of string * typ * expr
  | App   of expr * expr
  | Fix   of string * typ * expr
  | Strct of (string * expr) list
  | GetF  of expr * string
  | SetF  of expr * string * expr
  | Seq   of expr * expr 
  | For  of string * expr * expr * expr
  | While of expr * expr
type prog = {
    types: (string * strct) list;
    code: expr;
  }

(* Fonctions auxiliaires, utilisables pour gérer le sucre syntaxique
     let f (x1:t1) ... (xN:tN) = ...
   de définition d'une fonction à plusieurs arguments. *)
let rec mk_fun xs e = match xs with
  | [] -> e
  | (x, t)::xs -> Fun(x, t, mk_fun xs e)
  
let rec mk_fun_type xs t = match xs with
  | [] -> t
  | (_, t')::xs -> TFun(t', mk_fun_type xs t)
