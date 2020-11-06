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

(** Parser (not pur functionnal) *)

type parse_state =
  | Axiom
  | Rules
  | Interp
  | Done

let update_parse_state = function
  | Axiom -> Rules
  | Rules -> Interp
  | Interp | Done -> Done
;;

exception Invalid_word
exception Invalid_rule

(* Empty word representation. *)
let empty_word = Seq []

let read_line ci : string option =
  try
    let x = input_line ci in
    Some x
  with
  | End_of_file -> None
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

(* A valid rule string is of the form : <char><space><word> *)
let is_a_valid_str_rule str =
  (* Minimal valid rule is <char><space><char> (len = 3) *)
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

let add_new_char_rule_from_str (other_rules : char rewrite_rules) (str : string) =
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
     And initializes it with the basic rule. *)
  let rules_ref = ref (fun s -> Symb s) in
  List.iter
    (fun str ->
      if is_a_valid_str_rule str
         (* For each valid str in [str_list] append its corresponding rules. *)
      then rules_ref := add_new_char_rule_from_str !rules_ref str
      else raise Invalid_rule)
    str_list;
  !rules_ref
;;

(* let get_rules_from_line line = *)
(*   let splited_line = String.split_on_char ' ' line in *)
(*   if 2 <> List.length splited_line *)
(*   then raise NotValidRules *)
(*   else *)
(*     (function -> *)
(*   | List.hd splited_line -> create_char_word_from_str (List.nth 1 splited_line)) *)
(* ;; *)

(* TODO *)
let create_system_from_file (file_name : string) =
  let axiom_word = ref (Seq []) in
  (* let rules = ref (fun _ -> Seq []) in *)
  let current_parse_state = ref Axiom in
  let ci = open_in file_name in
  let line = ref (read_line ci) in
  while None <> !line && Done <> !current_parse_state do
    match !line with
    | None -> ()
    | Some l ->
      let curr_line = String.trim l in
      (* If it's an empty line, changes the current parse state. *)
      if 0 = String.length curr_line
      then
        current_parse_state := update_parse_state !current_parse_state
        (* If it's a commented line *)
      else if '#' <> curr_line.[0]
      then (
        match !current_parse_state with
        | Axiom ->
          print_string "\nAxiom = ";
          axiom_word := create_char_word_from_str curr_line
        | Rules -> print_string "\nRules = "
        (* if 3 <= String.length curr_line *)
        (* then rules := get_rules_from_line curr_line *)
        (* else raise NotValidRules *)
        | Interp ->
          print_string "\nInterp = ";
          print_string curr_line
        | Done -> print_string "\nDone.");
      line := read_line ci
  done;
  print_string "Finish.\n";
  close_in ci;
  { axiom = !axiom_word; rules = (fun s -> Symb s); interp = (fun _ -> [ Line 5 ]) }
;;
