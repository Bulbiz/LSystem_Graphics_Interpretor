open Turtle

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

(** Empty word representation. *)
let empty_word = Seq []

(** [interpret_word interpreter word colored draw curr_depth]
  interprets the word for graphical view and if [draw = true] draw lines otherwise just moves.
*)
let rec interpret_word interpreter word colored draw curr_depth =
  if colored then reset_color ();
  match word with
  | Symb s ->
    List.iter (fun cmd -> interpret_command cmd curr_depth colored draw) (interpreter s)
  | Branch w ->
    let curr_depth = curr_depth + 100 in
    interpret_command Store curr_depth colored draw;
    interpret_word interpreter w colored draw curr_depth;
    Turtle.interpret_command Restore curr_depth colored draw
  | Seq word_list ->
    List.iter (fun w -> interpret_word interpreter w colored draw curr_depth) word_list
;;

(** Models interpretation default values. *)
let default_interp = function
  | '[' -> [ Store ]
  | ']' -> [ Restore ]
  (* do nothing. *)
  | _ -> [ Turn 0 ]
;;

(** Prints a [char word], used for logging. *)
let rec print_char_word = function
  | Symb s -> print_char s
  | Seq l -> List.iter (fun w -> print_char_word w) l
  | Branch b ->
    print_string "[";
    print_char_word b;
    print_string "]"
;;

(** [apply_rules rules current_state] applies [rules] for each [current_state] symbols.
    @return the resulting state.
    *)
let rec apply_rules rules current_state =
  match current_state with
  | Symb s -> rules s
  | Branch w -> Branch (apply_rules rules w)
  | Seq word_list -> Seq (List.map (apply_rules rules) word_list)
;;

(** Calculates the nb of branches in a list of word. *)
let get_nb_branches_in word_list =
  (* Filter the list to obtains a list of all the Branch in word_list. *)
  List.filter
    (function
      | Branch _ -> true
      | _ -> false)
    word_list
  |> List.length
;;

(*(1** Is the current word depth used for creating word from string. *1) *)
(*let current_word_depth = ref 0 *)

let rec word_append_according_depth current_word current_word_depth w2 depth =
  match current_word with
  (* The current word contains only one [Symb] *)
  | Symb s -> Seq [ Symb s; w2 ]
  | Branch b -> Branch b (* Case never reached. *)
  | Seq word_list ->
    if current_word_depth = depth
    then (* In the last 'opened' branch. *)
      Seq (List.append word_list [ w2 ])
    else (
      (* Not in the last 'opened' branch. *)
      let nb_branches = get_nb_branches_in word_list in
      let rec transform_to_seq list current_branch =
        match list with
        | [] -> []
        | Branch b :: res ->
          if current_branch = nb_branches
          then
            Branch (word_append_according_depth b current_word_depth w2 (depth + 1))
            :: transform_to_seq res (current_branch + 1)
          else Branch b :: transform_to_seq res (current_branch + 1)
        | word :: res -> word :: transform_to_seq res current_branch
      in
      Seq (transform_to_seq word_list 1))
;;

(** [word_append current_word current_word_depth w2] appends [w2] to [current_word] according this rules :
      If [current_word] is a Symb,
        then creates a [Seq] with [current_word] followed by [w2].
      Else if [current_word] contains at least one 'opened' branch,
        then appends recursively [w2] to its last 'opened' branch
      Else,
        appends [w2] to the [current_word Seq list].

    A branch is 'opened' if '[' has been read and not ']'.
*)
let word_append current_word current_word_depth w2 =
  if empty_word <> w2
  then word_append_according_depth current_word current_word_depth w2 0
  else current_word
;;

let rec word_append_char_from word word_list current_word_depth =
  let char_to_word symb =
    match symb with
    (* Enterring in a new branch. *)
    | '[' -> Branch empty_word
    (* Exiting of the current branch. *)
    | ']' ->
      if 0 = current_word_depth
      then raise (Invalid_system "Invalid word '")
      else empty_word
    (* Simple char symbol. *)
    | symb -> Symb symb
  in
  match word_list with
  | [] -> word, current_word_depth
  | symb :: res ->
    let appended_word = word_append word current_word_depth (char_to_word symb) in
    (match symb with
    | '[' -> word_append_char_from appended_word res (current_word_depth + 1)
    | ']' -> word_append_char_from appended_word res (current_word_depth - 1)
    | _ -> word_append_char_from appended_word res current_word_depth)
;;

(** [create_char_word_from_str str]
    @return the [char word] corresponding to [str].
    @raise Invalid_system on errors.
    *)
let create_char_word_from_str str =
  if 1 = String.length str
  then (
    (* If [str] contains only one char. *)
    match str.[0] with
    (* It's not a valid word. *)
    | '[' | ']' -> raise (Invalid_system ("Invalid word '" ^ str ^ "'"))
    (* Returns the associated symbol. *)
    | c -> Symb c)
  else (
    try
      let explode_str = List.init (String.length str) (String.get str) in
      let word, current_word_depth = word_append_char_from empty_word explode_str 0 in
      (* If a branch isn't closed. *)
      if current_word_depth <> 0
      then raise (Invalid_system "Unclosed branch in '")
      else word
    with
    | Invalid_system msg -> raise (Invalid_system (msg ^ str ^ "'")))
;;

(* A valid string rule is of the form : <char>' '<word> *)
let is_a_valid_str_rule str =
  (* Minimal valid rule is <char>' '<char> (len = 3) *)
  if 3 > String.length str
  then false
  else (
    let str_list = String.split_on_char ' ' str in
    (* Should have at least two str <> of ' ' *)
    if 2 > List.length str_list
    then false
    else (
      (* First string should be a char => len = 1 *)
      let hd = List.hd str_list in
      1 = String.length hd))
;;

let create_new_char_rules (other_rules : char rewrite_rules) (str : string) =
  let str_list = String.split_on_char ' ' str in
  (* Gets the new rule arg symbol. *)
  let new_rule_symb = (List.hd str_list).[0] in
  (* Gets the new rule char word. *)
  let new_rule_char_word = create_char_word_from_str (List.nth str_list 1) in
  (* Returns the new rules. *)
  function
  | s when s = new_rule_symb -> new_rule_char_word
  | s -> other_rules s
;;

(** Creates a [char rewrite_rules] according to a given string list.

    @note If a symbol have more than one rule, the last one is used.
    @raise Invalid_system if a word or a rule is not valid.
*)
let create_char_rules_from_str_list str_list =
  let rec create_char_rules_reccursive rules list =
    match list with
    | [] -> rules
    | str :: res ->
      if is_a_valid_str_rule str
      then (
        let new_rules = create_new_char_rules rules str in
        create_char_rules_reccursive new_rules res)
      else raise (Invalid_system ("Invalid rule '" ^ str ^ "'"))
  in
  create_char_rules_reccursive (fun s -> Symb s) str_list
;;

(* A valid string interpretation is of the form : <char>' '<cmd>[' '<cmd>]. *)
let is_a_valid_str_interp str =
  if 4 > String.length str
  then false
  else (
    let str_list = String.split_on_char ' ' str in
    match str_list with
    | [] -> false
    | hd :: tlist ->
      (* The first string should contains only one char
         and all others strings should contains at least two chars.*)
      1 = String.length hd && List.for_all (fun s -> 1 < String.length s) tlist)
;;

(** [create_command_from_str str]
    @return the corresponding Turtle.command from [str].

    @raise Invalid_system if [str.[0]] doesn't correspond to a command.
    @raise Invalid_argument('index out of bounds') if [str] len < 2.
    @raise Failure('int_of_string') if the value isn't a number.
*)
let create_command_from_str str =
  let first_char = str.[0] in
  (* Get str[1:] *)
  let svalue = String.sub str 1 (String.length str - 1) in
  let signed = '-' == svalue.[0] in
  let value =
    match signed with
    (* value = -int_of_string (str[2:]) *)
    | true -> -1 * int_of_string (String.sub str 2 (String.length str - 2))
    (* value = int_of_string (str[1:]) *)
    | false -> int_of_string svalue
  in
  (* Returns the corresponding command. *)
  match first_char with
  | 'L' -> Line value
  | 'M' -> Move value
  | 'T' -> Turn value
  | c -> raise (Invalid_system ("Unknown command '" ^ String.make 1 c ^ "'"))
;;

(** @return a new interpretation with ...
    @raise Invalid_interp for an invalid input string.
*)
let create_new_char_interp interp str =
  let rec create_new_char_interp_reccursive command_list list =
    match list with
    | [] -> command_list
    | str :: res ->
      (try
         let new_command_list = command_list @ [ create_command_from_str str ] in
         create_new_char_interp_reccursive new_command_list res
       with
      | Failure _ -> raise (Invalid_system ("Invalid command '" ^ str ^ "'"))
      | Invalid_system msg -> raise (Invalid_system msg))
  in
  (* [commands_str] = str[2:] (removing the first char and space.)*)
  let commands_str = String.sub str 2 (String.length str - 2) in
  let commands_str_list = String.split_on_char ' ' commands_str in
  let command_list = create_new_char_interp_reccursive [] commands_str_list in
  function
  | s when s = str.[0] -> command_list
  | s -> interp s
;;

(** [create_char_interp_from_str_list str_list]
    @return a char interpretation of the string list.

    @raise Invalid_word if a word is not valid
    @raise Invalid_interp if a rule is not valid.

    @note If a symbol have more than one interpretation, the last one is used.
*)
let create_char_interp_from_str_list (str_list : string list) =
  let rec create_char_interp_reccursive interp list =
    match list with
    | [] -> interp
    | str :: res ->
      if is_a_valid_str_interp str
      then (
        let new_interp = create_new_char_interp interp str in
        create_char_interp_reccursive new_interp res)
      else raise (Invalid_system ("Invalid interpretation '" ^ str ^ "'"))
  in
  create_char_interp_reccursive default_interp str_list
;;

type parse_state =
  | Creating_axiom
  | Reading_rules
  | Creating_rules
  | Reading_interp
  | Done

let update_parse_state = function
  | Creating_axiom -> Reading_rules
  | Reading_rules -> Creating_rules
  | Creating_rules -> Reading_interp
  | Reading_interp -> Done
  | Done -> Done
;;

let read_line ci =
  try
    let x = input_line ci in
    Some x
  with
  | End_of_file -> None
;;

(* @note for IO we can not avoid side effects, however, although having limited
   them only in this function it seems too complicated and should be refactored but
   we are running out of time..
   *)
let create_system_from_file file_name =
  (* Initializes references with default values. *)
  let axiom_word_ref = ref empty_word in
  let char_rules_ref = ref (fun s -> Symb s) in
  let char_interp_ref = ref default_interp in
  (* Initializes the current parse state. *)
  let current_parse_state_ref = ref Creating_axiom in
  (* Opens the wanted file. *)
  let ci = open_in file_name in
  let line_ref = ref (read_line ci) in
  let line_list_ref = ref [] in
  while None <> !line_ref && Done <> !current_parse_state_ref do
    match !line_ref with
    | None -> ()
    | Some l ->
      let curr_line = String.trim l in
      (* If it's an empty line *)
      if 0 = String.length curr_line
      then
        (* updates the current parse state *)
        current_parse_state_ref := update_parse_state !current_parse_state_ref
      else if '#' <> curr_line.[0]
      then (
        (* Else if it is not a commented line,
           updates references according to the current parse state. *)
        match !current_parse_state_ref with
        | Creating_axiom -> axiom_word_ref := create_char_word_from_str curr_line
        (* During the [Reading_rules] and [Reading_interp],
           just appends the current line to [line_list_ref]. *)
        | Reading_rules | Reading_interp ->
          line_list_ref := !line_list_ref @ [ curr_line ]
        (* During the [Creating_rules],
           creates the char rules according the [line_list_ref] and reset [line_list_ref]. *)
        | Creating_rules ->
          char_rules_ref := create_char_rules_from_str_list !line_list_ref;
          line_list_ref := [ curr_line ];
          current_parse_state_ref := Reading_interp
        | _ -> ());
      (* Reads a new line.*)
      line_ref := read_line ci
  done;
  (* All files lines were readed. *)
  close_in ci;
  (* Creates char interpretations. *)
  char_interp_ref := create_char_interp_from_str_list !line_list_ref;
  (* Returns the char system. *)
  { axiom = !axiom_word_ref; rules = !char_rules_ref; interp = !char_interp_ref }
;;
