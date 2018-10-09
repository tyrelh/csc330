(*
	Tyrel Hiebert
	V00898825
	CSC 330 Programming Languages
	Assignment 3
*)

(* Assign 03 Provided Code *)

(*  Version 1.0 *)

exception NoAnswer

datatype pattern =
		Wildcard
		| Variable of string
		| UnitP
		| ConstP of int
		| TupleP of pattern list
		| ConstructorP of string * pattern

datatype valu =
		Const of int
	    | Unit
	    | Tuple of valu list
	    | Constructor of string * valu

(* Description of g:
	p is a pattern to check
	f1 is a handler for Wildcard cases and will return some int value
	f2 is a handler for Variable cases and takes the name of a variable and returns some int value

	g will return the value of a given pattern. If the given pattern is a TupleP, g will return the
	sum of all the values of each pattern within p recursively.
*)
fun g f1 f2 p =
    let
	val r = g f1 f2
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end


(**** put all your code after this line ****)


(* 1 *)
(* val only_capitals = fn : string list -> string list *)
fun only_capitals lst =
	List.filter (fn s => Char.isUpper(String.sub(s, 0))) lst


(* 2 *)
(* val longest_string1 = fn : string list -> string *)
fun longest_string1 lst =
	case lst of
		[] => ""
		| h::[] => h
		| _::_ =>
			List.foldl 
				(fn (a, b) => 
					if String.size(a) > String.size(b)
					then a
					else b
				) "" lst


(* 3 *)
(* val longest_string2 = fn : string list -> string *)
fun longest_string2 lst =
	case lst of
		[] => ""
		| h::[] => h
		| _::_ =>
			List.foldl 
				(fn (a, b) => 
					if String.size(a) >= String.size(b)
					then a
					else b
				) "" lst


(* 4 *)
(* val longest_string_helper = fn : (int * int -> bool) -> string list -> string *)
fun longest_string_helper f =
	foldl (
		fn (a, b) =>
			if f(String.size(a), String.size(b))
			then a
			else b
	) ""

(* val longest_string3 = fn : string list -> string *)
val longest_string3 = 
	longest_string_helper (
		fn (a, b) =>
			a > b
	)

(* val longest_string4 = fn : string list -> string *)
val longest_string4 = 
	longest_string_helper (
		fn (a, b) =>
			a >= b
	)


(* 5 *)
(* val longest_capitalized = fn : string list -> string *)
val longest_capitalized = longest_string3 o only_capitals


(* 6 *)
(* val rev_string = fn : string -> string *)
val rev_string = String.implode o List.rev o String.explode 



(* 7 *)
(* val first_answer = fn : ('a -> 'b option) -> 'a list -> 'b *)
fun first_answer f lst =
	case lst of
		[] => raise NoAnswer
		| a::b =>
			(case f a of
				SOME v => v
				| NONE => first_answer f b
			)


(* 8 *)
(* val all_answers = fn : ('a -> 'b list option) -> 'a list -> 'b list option *)
fun all_answers f l =
	let
		fun aux (lst, acc) =
			case lst of
			[] => SOME (acc)
			| a::b =>
				case f a of
					SOME v => aux(b, acc@v)
					| NONE => NONE
	in
		aux (l, [])
	end


(* 9 *)

(* b *)
(* val count_wildcards = fn : pattern -> int *)
fun count_wildcards p =
	g (fn _ => 1) (fn _ => 0) p

(* c *)
(* val count_wild_and_variable_lengths = fn : pattern -> int *)
fun count_wild_and_variable_lengths p =
	g (fn _ => 1) (fn x => String.size x) p

(* d *)
(* val count_some_var = fn : string * pattern -> int *)
fun count_some_var (s, p) =
	g (fn _ => 0) (fn x => if x = s then 1 else 0) p


(* 10 *)
(* val check_pat = fn : pattern -> bool *)
fun check_pat p =
	let
	  	fun builder (pat) =
			case pat of
				Variable v => [v]
				| TupleP lst => List.foldl (fn (x, y) => builder(x) @ y) [] lst
				| ConstructorP(_, a) => builder(a)
				| _ => []
		fun checker (lst) =
			case lst of
				[] => true
				| a::b =>
					if List.exists (fn x => a = x) b
					then false
					else checker(b)
	in checker(builder(p)) end


(* 11 *)
(* val match = fn : valu * pattern -> (string * valu) list option *)
fun match (v, p) =
	case p of
		Wildcard => SOME []
		| Variable s => SOME [(s, v)]
		| UnitP => 
			(case v of
				Unit => SOME []
				| _ => NONE
			)
		| ConstP x =>
			(case v of 
				Const y =>
					if x = y
					then SOME []
					else NONE
				| _ => NONE
			)
		| TupleP ps =>
			(case v of
				Tuple vs =>
					if List.length ps = List.length vs
					then (all_answers (match) (ListPair.zip(vs, ps)))
					else NONE
				| _ => NONE
			)
		| ConstructorP (s1, p1) =>
			(case v of
				Constructor (s2, v1) =>
					if s1 = s2
					then match (v1, p1)
					else NONE
				| _ => NONE
			)
		(* | _ => NONE *)


(* 12 *)
(* val first_match = fn : valu -> pattern list -> (string * valu) list option *)
fun first_match v l = 
	let fun make_curried f x y = f (x, y)
	in SOME (first_answer (make_curried match v) l) handle NoAnswer => NONE end