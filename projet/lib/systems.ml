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

(* FIXME :PlaceHolder, Have to be replaced by the L System we get from the parser *)
let system : char system= {
  axiom = Symb 'A';
  rules = (function 
    |s -> Symb s);
  interp = (function
    | _ -> [Turn 0]);
  }

(* current_state is the variable that store the current state of the LSystem*)
let current_state = ref system.axiom 

let next_state (rules) (current_state) = 
  let rec update_word (rules:'s rewrite_rules) (word:'s word)  =
    match word with
    |Symb s -> rules s
    |Branch (s) -> Branch (update_word rules s)
    |Seq word_list -> Seq (List.map (update_word rules) word_list)
  in
  update_word rules current_state

(* update_state will update the current_state with his next generation according to the system *)
let update_state () =
  current_state := next_state system.rules (!current_state);
  ()