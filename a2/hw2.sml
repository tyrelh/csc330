(*
    Tyrel Hiebert
    V00898825
*)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid some warning regarding polymorphic comparison  *)

fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for Part 1 here *)

(* 1 *)
fun all_except_option(s, l) =
    let
        fun bleh(s_, l_) = 
            case l_ of
            [] => []
            | a::b => 
                if same_string(s_, a)
                then bleh(s_, b)
                else a::bleh(s_,b)
        val searched = bleh(s, l)
    in
      if searched = l
      then NONE
      else SOME(searched)
    end
    
(* 2 *)
fun get_substitutions1(all_subs, s) =
    case all_subs of
        [] => []
        | a::b =>
            let
                val l = all_except_option(s, a) (* l is an option *)
                val r = get_substitutions1(b, s) (* r is a list *)
            in
                case l of
                    NONE => r
                    | SOME lst => lst @ r
            end

(* 3 *)
fun get_substitutions2(all_subs, s) =
    let
        fun aux(lists, acc)  =
            case lists of
                [] => acc
                | a::b =>
                    case all_except_option(s, a) of
                        NONE => aux(b, acc)
                        | SOME lst => aux(b, acc@lst)
    in aux(all_subs, [])
    end

(* 4 *)
fun similar_names(subs, {first=f, middle=m, last=l}) =
    let
        fun aux(lst, acc) =
            case lst of
                [] => acc
                | a::b => aux(b, acc@[ {first=a, middle=m, last=l} ])
    in aux(get_substitutions2(subs, f), [{first=f, middle=m, last=l}])
    end


(************************************************************************)
(* Game  *)

(* you may assume that Num is always used with valid values 2, 3, ..., 10 *)

datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw

exception IllegalMove

(* put your solutions for Part 2 here *)

(* 5 *)
fun card_color(c) = 
    case c of
        (Clubs, _) => Black
        | (Spades, _) => Black
        | (Diamonds, _) => Red
        | (Hearts, _) => Red

(* 6 *)
fun card_value(_, r) =
    case r of
        Ace => 11
        | Num a => a
        | _ => 10

(* 7 *)
fun remove_card(cs, c, e) =
    let
        fun aux(rem_cs, acc) =
            case rem_cs of
                [] => raise e
                | a::b =>
                    if a = c
                    then acc@b
                    else aux(b, acc@[a])
    in aux(cs, []) end

(* 8 *)
fun all_same_color(cards) =
    let
        fun aux(lst) =
            case lst
                of [] => true
                | x::[] => true
                | x::y::z =>
                    if card_color(x) <> card_color(y)
                    then false
                    else aux(y::z)
    in aux(cards) end

(* 9 *)
fun sum_cards(cards) =
    let
        fun aux(lst, acc) =
            case lst
                of [] => acc
                | a::b =>
                    aux(b, acc + card_value(a))
    in
        aux(cards, 0)
    end

(* 10 *)
fun score(hand, goal) =
    let
        val sum_hand = sum_cards(hand)
        val pre_score = 
            if sum_hand > goal
            then 2 * (sum_hand - goal)
            else (goal - sum_hand)
        val final_score = 
            if all_same_color(hand)
            then pre_score div 2
            else pre_score
    in final_score end

(* 11 *)
fun officiate(cardlist, movelist, goal) =
    let
        fun aux(rem_cards, rem_moves, hand) =
            case rem_moves
                of [] => score(hand, goal)
                | Discard c :: x => aux(rem_cards, x, remove_card(hand, c, IllegalMove))
                | Draw :: x =>
                    case rem_cards
                        of [] => score(hand, goal)
                        | a::b => 
                            if sum_cards(a::hand) > goal
                            then score(a::hand, goal)
                            else aux(b, x, a::hand)
    in
        aux(cardlist, movelist, [])
    end


(************************************************************************)
(* Tests  *)

val test1_0 = all_except_option("not",["sml","is","not","fun"]) = SOME ["sml","is","fun"];

val test2_0 = get_substitutions1([["Jim","Jimmy"],["Dan","Danny"],["J-Dog","Jim","J"]], "Jim") = ["Jimmy","J-Dog","J"];

val test3_0 = get_substitutions2([["Jim","Jimmy"],["Dan","Danny"],["J-Dog","Jim","J"]], "Jim") = ["Jimmy","J-Dog","J"];

val test4_0 = similar_names(
  [
    ["Where", "Who"],
    ["Insert", "Unused", "Name"],
    ["What", "Why", "When", "Who"]
  ],
  {first="Who", middle = "Is", last="This"}) 
=
  [
    {first = "Who", middle = "Is", last = "This"},
    {first = "Where", middle = "Is", last = "This"},
    {first = "What", middle = "Is", last = "This"},
    {first = "Why", middle = "Is", last = "This"},
    {first = "When", middle = "Is", last = "This"}
  ];

val test5_0 = card_color(Hearts, Num 5) = Red;

val test6_0 = card_value(Hearts, Ace) = 11;

exception notFound
val test_cards =[(Clubs, Ace), (Clubs, Num 10), (Spades, Num 4), (Clubs, Num 4)];
val test7_0 = remove_card(
    test_cards,
    (Spades, Num 4),
    notFound)
= [(Clubs, Ace), (Clubs, Num 10), (Clubs, Num 4)];

val test8_0 = all_same_color(test_cards) = true;

val test9_0 = sum_cards(test_cards) = 29;

val test10_0 = score(test_cards, 5) = 24;

val test11_0 = officiate(
    test_cards,
    [Draw, Discard(Clubs, Ace), Draw, Discard(Clubs, Num 10), Draw, Draw],
    5)
= 6;