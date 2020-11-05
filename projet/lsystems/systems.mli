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

val word_append : 's word -> 's word -> 's word
val create_char_word_from_str : string -> char word
val create_char_rules_from_str : string -> char -> char word
val create_system_from_file : string -> char system
val print_char_word : char word -> unit
