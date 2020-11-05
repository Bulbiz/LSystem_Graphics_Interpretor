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

(** [word_append w1 w2] appends [w2] to [w1] according this rules :
      If [w1] is a Symb,
        then creates a [Seq] with [w1] followed by [w2].
      Else if [w1] contains at least one 'opened' branch,
        then appends recursively [w2] to its last 'opened' branch
      Else,
        appends [w2] to the [w1 Seq list].

    A branch is 'opened' if '[' has been read and not ']'.
*)
val word_append : 's word -> 's word -> 's word

(** [create_char_word_from_str str]
    @return the [char word] corresponding to [str].
    @raise Invalid_word on errors. *)
val create_char_word_from_str : string -> char word

(** Create a [char word] according to a given string. *)
val create_char_rules_from_str : string -> char -> char word

(** Create a [char word] according to a given string. *)
val create_system_from_file : string -> char system

(** Print a [char word] with Seq represented by '|'. *)
val print_char_word : char word -> unit
