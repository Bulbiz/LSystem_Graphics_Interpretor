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

exception Invalid_system of string

(* Empty word representation. *)
val empty_word : 's word

(** Models interpretation default values. *)
val default_interp : char -> Turtle.command list

(** [interpret_word interpreter word colored draw curr_depth]
  interprets the word for graphical view and if [draw = true] draw lines otherwise just moves.
*)
val interpret_word : ('s -> Turtle.command list) -> 's word -> bool -> bool -> int -> unit

(** [apply_rules rules current_state] applies [rules] for each [current_state] symbols.
    @return the resulting state.
*)
val apply_rules : 's rewrite_rules -> 's word -> 's word

(** [word_append current_word current_word_depth w2] appends [w2] to [current_word] according this rules :
      If [current_word] is a Symb,
        then creates a [Seq] with [current_word] followed by [w2].
      Else if [current_word] contains at least one 'opened' branch,
        then appends recursively [w2] to its last 'opened' branch
      Else,
        appends [w2] to the [current_word Seq list].

    A branch is 'opened' if '[' has been read and not ']'.
*)
val word_append : 's word -> int -> 's word -> 's word

(** [create_char_word_from_str str]
    @return the [char word] corresponding to [str].

    @raise Invalid_system on errors. *)
val create_char_word_from_str : string -> char word

(** Creates a [char rewrite_rules] according to a given string list.

    @note If a symbol have more than one rule, the last one is used.

    @raise Invalid_system if a word or a rule is not valid.
*)
val create_char_rules_from_str_list : string list -> char -> char word

(** [create_command_from_str str]
    @return the corresponding Turtle.command from [str].

    @raise Invalid_system if [str.[0]] doesn't correspond to a command.
    @raise Invalid_argument('index out of bounds') if [str] len < 2.
    @raise Failure('int_of_string') if the value isn't a number.
*)
val create_command_from_str : string -> Turtle.command

(** [create_char_interp_from_str_list str_list]
    @return a char interpretation of the string list.

    @raise Invalid_word if a word is not valid
    @raise Invalid_interp if a rule is not valid.

    @note If a symbol have more than one interpretation, the last one is used.
*)
val create_char_interp_from_str_list : string list -> char -> Turtle.command list

(** [create_char_system_from_file file_name]
    @return the char system corresponding to a given file.

    @raise Invalid_system if the reprenstation of the system is invalid.
*)
val create_system_from_file : string -> char system

(** Prints a [char word]. *)
val print_char_word : char word -> unit

(*(1** Reset the current depth. *1) *)
(*val reset_current_depth : unit -> unit *)
