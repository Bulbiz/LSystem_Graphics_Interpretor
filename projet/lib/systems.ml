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

(* FIXME :PlaceHolder, Have to be replaced by the L System we get from the parser *)
let system : char system =
  { axiom = Symb 'A'
  ; rules =
      (function
      | s -> Symb s)
  ; interp =
      (function
      | _ -> [ Turn 0 ])
  }
;;

(* current_state is the variable that store the current state of the LSystem*)
let current_state_ref = ref system.axiom
let get_current_state () = !current_state_ref

let rec next_state rules current_state =
  match current_state with
  | Symb s -> rules s
  | Branch w -> Branch (next_state rules w)
  | Seq word_list -> Seq (List.map (next_state rules) word_list)
;;

let update_state () = current_state_ref := next_state system.rules !current_state_ref
