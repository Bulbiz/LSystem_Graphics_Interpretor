(** Words, rewrite systems, and rewriting *)
type 's word =
  | Symb of 's
  | Seq of 's word list
  | Branch of 's word

type 's rewrite_rules = 's -> 's word

type 's system = {
  axiom : 's word;
  rules : 's rewrite_rules;
  interp : 's -> Turtle.command list
}

(** Put here any type and function implementations concerning systems *)

let f_do_nothing =
  print_string "TODO.\n"

let return_0 = 0

let return_str = "Test string"

let update (l:'s system) = 
  match l.axiom with
  |Symb s -> l.rules s
  |Seq (q) -> (match q with
    | (Symb x) :: [] -> l.rules x
    | _ -> l.axiom)
  |_ -> l.axiom
