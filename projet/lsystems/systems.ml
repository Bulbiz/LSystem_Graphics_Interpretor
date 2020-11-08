open Turtle

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
exception Invalid_rule
exception Invalid_interp
exception Invalid_command

(* Empty word representation. *)
let empty_word = Seq []

let default_interp = function
  | '[' -> [ Store ]
  | ']' -> [ Restore ]
  (* do nothing. *)
  | _ -> [ Turn 0 ]
;;

let rec print_char_word = function
  | Symb s -> print_char s
  | Seq l ->
    print_string "|";
    List.iter (fun w -> print_char_word w) l;
    print_string "|"
  | Branch b ->
    print_string "[";
    print_char_word b;
    print_string "]"
;;

let rec next_state rules current_state =
  match current_state with
  | Symb s -> rules s
  | Branch w -> Branch (next_state rules w)
  | Seq word_list -> Seq (List.map (next_state rules) word_list)
;;

let get_nb_branches_in (word_list : 's word list) : int =
  let nb_branches = ref 0 in
  List.iter
    (fun w ->
      match w with
      | Branch _ -> nb_branches := !nb_branches + 1
      | _ -> ())
    word_list;
  !nb_branches
;;

let current_word_depth = ref 0

let rec word_append_according_depth (current_word : 's word) (w2 : 's word) (depth : int) =
  match current_word with
  (* The current word contains only one [Symb] *)
  | Symb s -> Seq [ Symb s; w2 ]
  | Branch b -> Branch b (* Case never reached. *)
  | Seq word_list ->
    if !current_word_depth = depth
    then (* In the last 'opened' branch. *)
      Seq (List.append word_list [ w2 ])
    else (
      (* Not in the last 'opened' branch. *)
      let nb_branches = get_nb_branches_in word_list in
      let curr_branch = ref 0 in
      (* Finds the last 'opened' branch recursively. *)
      Seq
        (List.map
           (function
             | Branch b ->
               curr_branch := !curr_branch + 1;
               if !curr_branch = nb_branches
                  (* Last branch of the current word Seq found. *)
               then Branch (word_append_according_depth b w2 (depth + 1))
               else Branch b (* Not the last branch. *)
             | word -> word)
           word_list))
;;

let word_append (w1 : 's word) (w2 : 's word) =
  if empty_word <> w2 then word_append_according_depth w1 w2 0 else w1
;;

let word_append_char_from (word_ref : char word ref) (symb : char) : unit =
  word_ref
    := word_append
         !word_ref
         (match symb with
         (* Enterring in a new branch. *)
         | '[' -> Branch empty_word
         (* Exiting of the current branch. *)
         | ']' -> if 0 = !current_word_depth then raise Invalid_word else empty_word
         (* Simple char symbol. *)
         | symb -> Symb symb);
  match symb with
  | '[' -> current_word_depth := !current_word_depth + 1
  | ']' -> current_word_depth := !current_word_depth - 1
  | _ -> ()
;;

let create_char_word_from_str str =
  if 1 = String.length str
  then (
    (* If [str] contains only one char. *)
    match str.[0] with
    (* It's not a valid word. *)
    | '[' | ']' -> raise Invalid_word
    (* Returns the associated symbol. *)
    | c -> Symb c)
  else (
    current_word_depth := 0;
    (* Uses a [char word ref] in order able to modify its value through [List.iter]. *)
    let word_ref = ref empty_word in
    String.iter (fun symb -> word_append_char_from word_ref symb) str;
    (* If a branch isn't closed. *)
    if !current_word_depth <> 0 then raise Invalid_word else !word_ref)
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

let create_char_rules_from_str_list str_list =
  (* Uses a ref in order to iterate and modified through the [str_list].
    Initializes it with the basic rule. *)
  let rules_ref = ref (fun s -> Symb s) in
  List.iter
    (fun str ->
      if is_a_valid_str_rule str
         (* For each valid str in [str_list] append its corresponding rules. *)
      then rules_ref := create_new_char_rules !rules_ref str
      else raise Invalid_rule)
    str_list;
  !rules_ref
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
  | _ -> raise Invalid_command
;;

(** @return a new interpretation with ...
    @raise Invalid_interp for an invalid input string.
*)
let create_new_char_interp (interp : char -> command list) (str : string)
    : char -> command list
  =
  let command_list = ref [] in
  (* [commands_str] = str[2:] (removing the first char and space.)*)
  let commands_str = String.sub str 2 (String.length str - 2) in
  let commands_str_list = String.split_on_char ' ' commands_str in
  List.iter
    (fun str ->
      (* Try to add a new char command if the command is valid. *)
      try command_list := !command_list @ [ create_command_from_str str ] with
      (* NOTE: maybe it should be refactor with options. *)
      | Failure _ | Invalid_argument _ | Invalid_command -> raise Invalid_interp)
    commands_str_list;
  (* Returns the new interpretation. *)
  function
  | s when s = str.[0] -> !command_list
  | s -> interp s
;;

let create_char_interp_from_str_list (str_list : string list) =
  (* Uses a ref in order to iterate and modified through the [str_list].
    Initializes it with the default case. *)
  let interp_ref = ref default_interp in
  List.iter
    (fun str ->
      if is_a_valid_str_interp str
      then interp_ref := create_new_char_interp !interp_ref str
      else raise Invalid_interp)
    str_list;
  (* Returns the interpretation. *)
  !interp_ref
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

let read_line ci : string option =
  try
    let x = input_line ci in
    Some x
  with
  | End_of_file -> None
;;

let create_system_from_file (file_name : string) =
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
      (* If it's an empty line, updates the current parse state. *)
      if 0 = String.length curr_line
      then current_parse_state_ref := update_parse_state !current_parse_state_ref
      else if '#' <> curr_line.[0]
      then (
        (* If it is not a commented line,
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
