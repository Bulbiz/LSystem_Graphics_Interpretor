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


(* Get the next generation from current_state by applying the rules to each Symb*)
let next_state (rules:'s rewrite_rules) (current_state:'s word) = 
  let rec update_word (rules:'s rewrite_rules) (word:'s word)  =
    match word with
    |Symb s -> rules s
    |Branch (s) -> Branch (update_word rules s)
    |Seq (q) -> Seq(update_sequence rules q)
  
    (* Return a list of updated word *)
  and update_sequence (rules:'s rewrite_rules) (sequence:'s word list)  =
    match sequence with
    | [] -> []
    | [s] -> [update_word rules s]
    | w :: rest -> update_word rules w :: update_sequence rules rest
  in
  update_word rules current_state



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

(* update_state will update the current_state with his next generation according to the system *)
let update_state () =
  current_state := next_state system.rules (!current_state);
  ();;