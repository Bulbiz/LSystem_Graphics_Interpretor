(** Words, rewrite systems, and rewriting *)
type 's word =
  | Symb of 's
  | Seq of 's word list
  | Branch of 's word

type 's rewrite_rules = 's -> 's word

type 's system =
  { axiom : 's word
  ; rules : 's rewrite_rules
  ; interp : 's -> Turtle.command list
  }

(** [get_current_state]
    @return the [current_state]
*)
val get_current_state : unit -> char word

(** [next_state rules current_state] applies [rules] for each [current_state] symbols.
    @return the resulting state.
*)
val next_state : 's rewrite_rules -> 's word -> 's word

(** [update_state] updates the global [current_state] with [next_state]. *)
val update_state : unit -> unit
