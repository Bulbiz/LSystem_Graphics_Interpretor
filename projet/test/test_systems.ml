open OUnit2
open Lsystems.Systems
open Lsystems.Turtle

let default_interp = Turn 0

let assert_for_each_symbol s_list expected_rules actual_rules =
  List.iter (fun s -> assert_equal (expected_rules s) (actual_rules s)) s_list
;;

let systems_suite =
  "Systems suite"
  >::: [ (*

            Systems.create_char_word_from_str tests related.

        *)
         ("Systems.create_char_word_from_str with one char."
         >:: fun _ -> assert_equal (Symb 'A') (create_char_word_from_str "A"))
       ; ("Systems.create_char_word_from_str with a normal word string."
         >:: fun _ ->
         assert_equal (Seq [ Symb 'A'; Symb 'B' ]) (create_char_word_from_str "AB"))
       ; ("Systems.create_char_word_from_str with a root branch based word."
         >:: fun _ ->
         assert_equal
           (Seq [ Branch (Seq [ Symb 'A'; Symb 'B' ]) ])
           (create_char_word_from_str "[AB]"))
       ; ("Systems.create_char_word_from_str should raise an Invalid_word exception with \
           ']' as argument."
         >:: fun _ -> assert_raises Invalid_word (fun () -> create_char_word_from_str "]")
         )
       ; ("Systems.create_char_word_from_str should raise an Invalid_word exception with \
           '[' as argument."
         >:: fun _ -> assert_raises Invalid_word (fun () -> create_char_word_from_str "[")
         )
       ; ("Systems.create_char_word_from_str should raise an Invalid_word exception with \
           too many closing brackets."
         >:: fun _ ->
         assert_raises Invalid_word (fun () -> create_char_word_from_str "[AB]A[VC]][A]")
         )
       ; ("Systems.create_char_word_from_str should raise an Invalid_word exception with \
           enclosed branches."
         >:: fun _ ->
         assert_raises Invalid_word (fun () -> create_char_word_from_str "[AB]A[VC[A]"))
       ; ("Systems.create_char_word_from_str with a normal branched string word."
         >:: fun _ ->
         let expected_word =
           Seq
             [ Symb 'B'
             ; Branch (Seq [ Symb '+'; Symb 'A' ])
             ; Branch (Seq [ Symb '-'; Symb 'A' ])
             ; Symb 'B'
             ; Symb 'A'
             ]
         in
         let actual_word = create_char_word_from_str "B[+A][-A]BA" in
         assert_equal expected_word actual_word)
       ; ("Systems.create_char_word_from_str with a double branched string word."
         >:: fun _ ->
         let expected_word =
           Seq
             [ Symb 'B'
             ; Branch (Seq [ Symb '+'; Branch (Seq [ Symb 'B'; Symb 'A' ]); Symb 'A' ])
             ; Branch (Seq [ Symb '-'; Symb 'A' ])
             ; Symb 'B'
             ; Symb 'A'
             ]
         in
         let actual_word = create_char_word_from_str "B[+[BA]A][-A]BA" in
         assert_equal expected_word actual_word)
       ; ("Systems.create_char_word_from_str with a hardly recursively branched string \
           word."
         >:: fun _ ->
         let expected_word =
           Seq
             [ Symb 'B'
             ; Branch (Seq [ Symb '+'; Branch (Seq [ Symb 'B'; Symb 'A' ]); Symb 'A' ])
             ; Branch
                 (Seq
                    [ Symb '-'
                    ; Branch
                        (Seq [ Symb '+'; Branch (Seq [ Symb '$'; Symb 'A' ]); Symb 'A' ])
                    ; Symb 'A'
                    ])
             ; Symb 'B'
             ; Symb 'A'
             ; Branch
                 (Seq
                    [ Symb '-'
                    ; Branch
                        (Seq [ Symb '+'; Branch (Seq [ Symb '$'; Symb 'A' ]); Symb 'A' ])
                    ; Symb 'X'
                    ])
             ]
         in
         let actual_word =
           create_char_word_from_str "B[+[BA]A][-[+[$A]A]A]BA[-[+[$A]A]X]"
         in
         assert_equal expected_word actual_word)
         (*

            Systems.create_char_rules_from_str_list tests related.

        *)
       ; ("Systems.create_char_rules_from_str_list with a simple string word."
         >:: fun _ ->
         let expected_rules = function
           | 'B' -> Seq [ Symb 'B'; Symb 'B' ]
           | s -> Symb s
         in
         let actual_rules = create_char_rules_from_str_list [ "B BB" ] in
         assert_for_each_symbol [ 'B'; '+' ] expected_rules actual_rules)
       ; ("Systems.create_char_rules_from_str_list with two branched string words."
         >:: fun _ ->
         let expected_rules = function
           | 'B' -> Seq [ Symb 'B'; Symb 'B' ]
           | 'C' -> Seq [ Branch (Seq [ Symb 'B'; Symb 'B' ]); Symb '+' ]
           | s -> Symb s
         in
         let actual_rules = create_char_rules_from_str_list [ "B BB"; "C [BB]+" ] in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_rules actual_rules)
       ; ("Systems.create_char_rules_from_str_list with two branched string words."
         >:: fun _ ->
         let expected_rules = function
           | 'B' -> Seq [ Branch (Seq [ Symb 'B'; Symb 'B' ]); Symb '+'; Symb '-' ]
           | 'C' -> Seq [ Branch (Seq [ Symb 'B'; Symb 'B' ]); Symb '+' ]
           | s -> Symb s
         in
         let actual_rules =
           create_char_rules_from_str_list [ "B BB"; "C [BB]+"; "B [BB]+-" ]
         in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_rules actual_rules)
       ; ("Systems.create_char_rules_from_str_list should raises an exception with an \
           empty string."
         >:: fun _ ->
         assert_raises Invalid_rule (fun () -> create_char_rules_from_str_list [ "" ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that not contains the rewrited word."
         >:: fun _ ->
         assert_raises Invalid_rule (fun () -> create_char_rules_from_str_list [ "C " ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that not begin with a single char."
         >:: fun _ ->
         assert_raises Invalid_rule (fun () ->
             create_char_rules_from_str_list [ "CDFD SFAFA" ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that contains a not valid word."
         >:: fun _ ->
         assert_raises Invalid_word (fun () ->
             create_char_rules_from_str_list [ "C [asdf][" ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that contains a not valid word."
         >:: fun _ ->
         assert_raises Invalid_word (fun () ->
             create_char_rules_from_str_list [ "C [asdf][" ]))
         (*

            Systems.create_command_from_str tests related.

        *)
       ; ("Systems.create_command_from_str with a valid string with a positive figure."
         >:: fun _ -> assert_equal (Line 5) (create_command_from_str "L5"))
       ; ("Systems.create_command_from_str with a valid string with a negative figure."
         >:: fun _ -> assert_equal (Line (-5)) (create_command_from_str "L-5"))
       ; ("Systems.create_command_from_str with a valid string with a negative number."
         >:: fun _ -> assert_equal (Move (-543)) (create_command_from_str "M-543"))
       ; ("Systems.create_command_from_str should reaise an Invalid_command with a \
           string starting with an invalid command init."
         >:: fun _ ->
         assert_raises Invalid_command (fun () -> create_command_from_str "C4"))
       ; ("Systems.create_command_from_str should reaise an Invalid_argument 'index out \
           of bounds' with a string with no value."
         >:: fun _ ->
         assert_raises (Invalid_argument "index out of bounds") (fun () ->
             create_command_from_str "C"))
       ; ("Systems.create_command_from_str 'int_of_string' should fail with a string \
           with an invalid value."
         >:: fun _ ->
         assert_raises (Failure "int_of_string") (fun () -> create_command_from_str "C2@")
         )
         (*

            Systems.create_char_interp_from_str_list tests related.

        *)
       ; ("Systems.create_char_interp_from_str_list with a valid string."
         >:: fun _ ->
         todo "todo";
         let expected_interp = function
           | 'B' -> [ Line 5 ]
           | _ -> [ default_interp ]
         in
         let actual_interp = create_char_interp_from_str_list [ "B L5" ] in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_interp actual_interp)
       ; ("Systems.create_char_interp_from_str_list with a valid list of string."
         >:: fun _ ->
         todo "todo";
         let expected_interp = function
           | 'A' -> [ Line 5 ]
           | 'B' -> [ Line 5 ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25) ]
           | _ -> [ default_interp ]
         in
         let actual_interp =
           create_char_interp_from_str_list [ "A L5"; "B L5"; "+ T25"; "- T-25" ]
         in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_interp actual_interp)
       ; ("Systems.create_system_from_file with br3.sys should create a valid char \
           system."
         >:: fun _ ->
         skip_if true "TODO : create_system_from_file with br3.sys";
         let system = create_system_from_file "../../../test/resources/br3.sys" in
         (* Verify system.axiom. *)
         let expected_axiom = Symb 'A' in
         assert_equal expected_axiom system.axiom;
         (* Verify system.rules. *)
         let expected_rules = function
           | 'A' -> Symb 'A'
           | 'B' -> Seq [ Symb 'B'; Symb 'B' ]
           | s -> Symb s
         in
         assert_for_each_symbol [ 'A'; 'B' ] expected_rules system.rules)
       ]
;;

let () = run_test_tt_main systems_suite
