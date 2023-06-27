open Mml

(* Environnement de typage : associe des types aux noms de variables *)
module SymTbl = Map.Make(String)
type tenv = typ SymTbl.t

(* Pour remonter des erreurs circonstanciées *)
exception Type_error of string
let error s = raise (Type_error s)
let type_error ty_actual ty_expected =
 error (Printf.sprintf "expected %s but got %s" 
 (typ_to_string ty_expected) (typ_to_string ty_actual))
(* vous pouvez ajouter d'autres types d'erreurs *)


(*pour obtenir le champ mutable *)
let get_mutable (_,_,a) = a 
let get_type_from_strct(_,a,_) = a 

(* Vérification des types d'un programme *)
let type_prog prog =

 (* Vérifie que l'expression [e] a le type [type] *)
 let rec check e typ tenv =
 let typ_e = type_expr e tenv in
 if typ_e <> typ then type_error typ_e typ
 

 and check_champ (t: strct) (l) tenv =
    List.for_all2 (fun (str1,t,_) (str2,e) -> (check e t tenv); str1=str2) t l
 and check_structures (types: (string*strct) list) (l) tenv = 
    (match types with |[] -> error "la structure n'a pas été trouvée"|hd::li -> 
    if (check_champ (snd hd) l tenv) then TStrct(fst hd) else (check_structures li l tenv))
 and type_expr e tenv = match e with
 | Int _ -> TInt
 | Bool(p) -> TBool
 | Unit  -> TUnit

 | Uop(Neg,e) -> 
 check e TInt tenv; TInt
 | Uop(Not,e)->
 check e TBool tenv; TBool

 | Bop((Add | Mul | Sub|Div|Mod), e1, e2) -> 
 check e1 TInt tenv; check e2 TInt tenv; TInt
 | Bop((Lt | Le),e1,e2) ->
 check e1 TInt tenv; check e2 TInt tenv; TBool
 | Bop((Eq| Neq),e1,e2) ->
 let typ2 = type_expr e2 tenv in 
 check e1 typ2 tenv; TBool
 |Bop((And|Or),e1,e2) -> 
 check e1 TBool tenv; check e2 TBool tenv; TBool

 |For(s,e1,e2,e3) -> 
  check e1 TInt tenv;
  check e2 TInt tenv;
  let typ3 = type_expr e3 (SymTbl.add s TInt tenv) in 
  (*if typ3 <> TUnit then warning "For: e3 is not of type Unit";*)
  TUnit

  |While(e1,e2) -> 
    check e1 TBool tenv;
    let typ2 = type_expr e2 tenv in 
    if typ2 <> TUnit then Printf.printf "Warning, in a While e1 do e2 !  e2 is not of type Unit";
    TUnit


 (*|Bop ((Sub|Div|Mod|Neq|And|Or), _, _) -> error (Printf.sprintf "il faut appliquer les operations binaires sur des boolens ou entiers")*)

 | If(e0,e1,e2) ->
 check e0 TBool tenv;
 let t = type_expr e1 tenv in 
 check e2 t tenv ; t

 |Var(e) -> 
 let typ = (SymTbl.find e tenv) in typ

 |Let(s,e1,e2) ->
 let typ1 = type_expr e1 tenv in 
 let typ2 = type_expr e2 (SymTbl.add s typ1 tenv) in 
 typ2

 |Fun(s,typ,e) -> 
 TFun(typ ,(type_expr e (SymTbl.add s typ tenv)))

 |App(e1,e2) -> 
 let typ1 = type_expr e1 tenv in 
 (match typ1 with |TFun(t2,t1) -> check e2 t2 tenv; t1 |typ_e -> error (Printf.sprintf "expected type function but got %s" (typ_to_string typ_e)))

 |Fix(x,t1,e) -> 
 let t2 = type_expr e (SymTbl.add x t1 tenv) in t2 

 |Seq(e1,e2) -> 
 let t1 = type_expr e1 tenv in 
 if t1 <> TUnit then Printf.printf "Warning, in a sequence e1;e2 !  e1 is not of type Unit";
 let t2 = type_expr e2 tenv in t2

 |GetF(e,x) -> 
 let s = type_expr e tenv in 
 (match s with |TStrct(typ) -> (let structure = snd (List.find (fun t -> fst t = typ) prog.types) in 
  get_type_from_strct (List.find (fun (str,t,m) -> str = x) structure) ) |typ -> type_error s typ ) 

 |SetF(e1,x,e2) -> 
 let s = type_expr e1 tenv in 
 let t2 = type_expr e2 tenv in 
 begin match s with |TStrct(typ) -> let structure = snd (List.find (fun t -> fst t = typ) prog.types) in 
 let champ =  (List.find (fun (str,t,mut) -> str = x) structure) in if get_mutable(champ) then (if ((get_type_from_strct champ) = t2) then TUnit else error (Printf.sprintf "e2 does not have the same type as e.x")) else error (Printf.sprintf "e.x is not mutable")
 |typ -> type_error s typ end

 |Strct(lst) ->
    check_structures prog.types lst tenv;
  
  (*and print_strct (s: string * strct) : string = 
  (match s with |(str,strc)-> (String.concat ":" [str;(strct_to_string strc)] ))
  and strct_to_string (strc:(string * typ * bool) list) : string = 
  (match strc with |[] -> "" |s::l -> (String.concat "|" [(champ_to_string s);(strct_to_string l)]))
  and champ_to_string (strc:string * typ * bool): string =
  (match strc with |(str,t,b)-> String.concat ";" [str;(typ_to_string t);(bool_to_string b)])
  and bool_to_string b = if b then "true" else "false"*)
 in


 type_expr prog.code SymTbl.empty
