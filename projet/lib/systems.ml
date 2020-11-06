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


let update (rules:'s rewrite_rules) (word:'s word) = 
  let rec update_aux (rules:'s rewrite_rules) (word:'s word)  =
    match word with
    |Symb s -> rules s
    |Branch (s) -> Branch (update_aux rules s)
    |Seq (q) -> Seq(update_sequence rules q)(*Seq(List.map (update_aux rules) q)*)

  and update_sequence (rules:'s rewrite_rules) (sequence:'s word list)  =
    match sequence with
    | [] -> failwith "Shouldn't happen"
    | [s] -> [update_aux rules s]
    | x :: q -> update_aux rules x :: update_sequence rules q
  in
  update_aux rules word

  let next_state (rules:'s rewrite_rules) (current_state:'s word) =
    update rules current_state
    (*
    match rules with
    |_->( match current_state with
      |Symb 'A' -> Seq [Symb 'A';Symb 'A';Symb 'A']
      |Branch(Seq [Symb 'A';Symb 'B']) -> Branch(Seq [Branch (Seq[Symb 'A';Symb 'B']);Symb 'A'])
      | _ -> failwith ("oof") 
    )
    *)