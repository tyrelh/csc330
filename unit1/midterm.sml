(* MIDTERM 1 PREP
Standard ML *)


(* Practice Midterm 1 *)


(* Tail Recursive Fibbonacci *)
fun fib n =
  let
    fun aux (d, two, one) =
      if d = n
      then one
      else aux (d + 1, one, two + one)
  in aux (1, 0, 1) end

val testThirdFib = fib 3 = 2
val testSeventhFib = fib 7 = 13


(* BINARY TREES *)

datatype tree = EmptyT 
  | Tree of (int*tree*tree)

(* Binary Tree Insertion *)
fun insert (t, n) =
  case t of
    EmptyT => Tree(n, EmptyT, EmptyT)
    | Tree(i, l, r) =>
      if n > i
      then Tree(i, l, insert(r, n))
      else Tree(i, insert(l, n), r)

val treeA = insert(insert(EmptyT,2),2)
val treeB = insert(insert(insert(EmptyT,3),2),5)
val treeC = insert(insert(insert(insert(insert(insert(insert(EmptyT, 1), 2), 3), 4), 5), 6), 7)
val testInsertA = treeA = Tree (2,Tree (2,EmptyT,EmptyT),EmptyT)
val testInsertB = treeB = Tree (3,Tree (2,EmptyT,EmptyT),Tree (5,EmptyT,EmptyT))

(* Binary Tree Fold *)
fun fold_tree f acc t =
  case t of
    EmptyT => acc
    | Tree(i, l, r) =>
      let
        val left_result = f((fold_tree f acc l), i)
      in (fold_tree f left_result r) end

val testFold1 = fold_tree (fn (a, v) => a @ [v]) [] treeB
val testFold2 = fold_tree (fn (a, v) => a + v) 0 treeB
val testFold3 = fold_tree (fn (a, v) => a @ [v]) [] treeC

(* int to string example helper function *)
fun to_string(acc, i) =
  if acc = ""
  then Int.toString(i)
  else acc ^ " " ^ Int.toString(i)

(* Convert tree to string using fold and to_string helper *)
val tree_to_string =
  fold_tree (to_string) ""


val stringC = tree_to_string treeC
val testTreeToStringC = stringC = "1 2 3 4 5 6 7"

(* Practice midterm 2 *)

(* Reverse List *)
fun rev l =
  let
    fun aux(rem, acc) =
      case rem of
        [] => acc
        | a::b =>
          aux(b, a::acc)
  in aux(l, []) end

val testRevList = rev testFold3


(* Split List on Even/Odd indecies *)
fun lst_split l =
  let 
    fun aux (rem, accA, accB) =
      case rem of
        [] => (accA, accB)
        | a::[] => (accA@[a], accB)
        | a::b::c => aux(c, accA@[a], accB@[b])
  in aux(l, [], []) end

val testListSplit = lst_split testFold3


(* map given on exam *)
fun map (f, xs) =
  case xs of
    [] => []
    | x::xs' => (f x) :: map(f, xs')

(* make a list into a list of lists *)
fun listify l =
  map((fn x => [x]), l)

val testListify = listify testFold3

(* generator *)
fun create_stream f init = 
  let
    val c = ref(init - 1)
  in
    (fn () => (
      (c := !c + 1); f(!c)
    ))
  end

val a = create_stream fib 1


fun zip2 lists =
  case lists of
    (h1::t1, h2::t2) =>
      (h1, h2) :: zip2(t1, t2)
    | _ => []

val testZip2 = zip2 (testFold3, testFold3)

fun tailRecursiveZip2 lists =
  let fun aux(acc, rem) =
    case rem of
      (h1::t1, h2::t2) =>
        aux(acc@[(h1, h2)], (t1, t2))
      | _ => acc
  in aux([], lists) end

val testTailRecursiveZip2 = tailRecursiveZip2 (testFold3, testFold3)

fun unzip2 tuples =
  case tuples of
    [] => ([], [])
    | (a, b)::t =>
      let val (l1, l2) = unzip2 t
      in (a::l1, b::l2) end

val testUnzip2 = unzip2 testZip2


fun tailRecursiveUnzip2 tuples =
  let fun aux(ac1, ac2, rem) =
    case rem of
      [] => (ac1, ac2)
      | (a, b)::t =>
        aux(ac1@[a], ac2@[b], t)
  in aux([], [], tuples) end

val testTRUnzip2 = tailRecursiveUnzip2 testZip2