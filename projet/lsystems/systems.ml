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

let create_system_from_file (_: string) =
  {
    axiom  = Symb 'A';
    rules  = (fun a -> Symb a);
    interp = (fun _ -> [Line 0])
  };;
