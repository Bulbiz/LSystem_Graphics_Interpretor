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

(** Put here any type and function interfaces concerning systems *)

val f_do_nothing : unit

val return_0 : int

val return_str : string

(* Get the next generation from current_state by applying the rules to each Symb*)
val next_state :('s  rewrite_rules) -> ('s word) -> ('s word)

val update_state: (char system) -> unit