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

exception Invalid_word

(** [word_append current_word w2] appends [w2] to [current_word] according this rules :
      If [current_word] is a Symb,
        then creates a [Seq] with [current_word] followed by [w2].
      Else if [current_word] contains at least one 'opened' branch,
        then appends recursively [w2] to its last 'opened' branch
      Else,
        appends [w2] to the [current_word Seq list].

    A branch is 'opened' if '[' has been read and not ']'.
*)
val word_append : 's word -> 's word -> 's word

(** [create_char_word_from_str str]
    @return the [char word] corresponding to [str].
    @raise Invalid_word on errors. *)
val create_char_word_from_str : string -> char word

(** Creates a [char rewrite_rules] according to a given string. *)
val create_char_rules_from_str : string -> char -> char word

(** Creates a [char system] according to a given string. *)
val create_system_from_file : string -> char system

(** Prints a [char word] with Seq represented by '|'. *)
val print_char_word : char word -> unit
