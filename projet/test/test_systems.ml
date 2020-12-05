open OUnit2
open Lsystems.Systems
open Lsystems.Turtle

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
       ; ("Systems.create_char_word_from_str should raise an Invalid_system exception \
           with ']' as argument."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid word ']'") (fun () ->
             create_char_word_from_str "]"))
       ; ("Systems.create_char_word_from_str should raise an Invalid_system exception \
           with '[' as argument."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid word '['") (fun () ->
             create_char_word_from_str "["))
       ; ("Systems.create_char_word_from_str should raise an Invalid_system exception \
           with too many closing brackets."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid word '[AB]A[VC]][A]'") (fun () ->
             create_char_word_from_str "[AB]A[VC]][A]"))
       ; ("Systems.create_char_word_from_str should raise an Invalid_system exception \
           with enclosed branches."
         >:: fun _ ->
         assert_raises (Invalid_system "Unclosed branch in '[AB]A[VC[A]'") (fun () ->
             create_char_word_from_str "[AB]A[VC[A]"))
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
         assert_raises (Invalid_system "Invalid rule ''") (fun () ->
             create_char_rules_from_str_list [ "" ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that not contains the rewrited word."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid rule 'C '") (fun () ->
             create_char_rules_from_str_list [ "C " ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that not begin with a single char."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid rule 'CDFD SFAFA'") (fun () ->
             create_char_rules_from_str_list [ "CDFD SFAFA" ]))
       ; ("Systems.create_char_rules_from_str_list should raises an exception with a \
           string that contains a not valid word."
         >:: fun _ ->
         assert_raises (Invalid_system "Unclosed branch in '[asdf]['") (fun () ->
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
         assert_raises (Invalid_system "Unknown command 'C'") (fun () ->
             create_command_from_str "C4"))
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
       ; ("Systems.create_char_interp_from_str_list with a valid string command."
         >:: fun _ ->
         let expected_interp = function
           | 'B' -> [ Line 5 ]
           | _ -> [ default_command ]
         in
         let actual_interp = create_char_interp_from_str_list [ "B L5" ] in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_interp actual_interp)
       ; ("Systems.create_char_interp_from_str_list with a valid string command."
         >:: fun _ ->
         let expected_interp = function
           | 'A' -> [ Line 5 ]
           | 'B' -> [ Line 5 ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25) ]
           | _ -> [ default_command ]
         in
         let actual_interp =
           create_char_interp_from_str_list [ "A L5"; "B L5"; "+ T25"; "- T-25" ]
         in
         assert_for_each_symbol [ 'A'; 'B'; 'C'; '+' ] expected_interp actual_interp)
       ; ("Systems.create_char_interp_from_str_list with a multiple valid string \
           commands."
         >:: fun _ ->
         let expected_interp = function
           | 'B' -> [ Line 5; Line (-10); Move 104 ]
           | _ -> [ default_command ]
         in
         let actual_interp = create_char_interp_from_str_list [ "B L5 L-10 M104" ] in
         assert_for_each_symbol [ 'B'; 'C'; '+' ] expected_interp actual_interp)
       ; ("Systems.create_char_interp_from_str_list with multiple valid string commands."
         >:: fun _ ->
         let expected_interp = function
           | 'A' -> [ Line 5; Turn (-30) ]
           | 'B' -> [ Line 5 ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25); Line 5; Move (-100) ]
           | _ -> [ default_command ]
         in
         let actual_interp =
           create_char_interp_from_str_list
             [ "A L5 T-30"; "B L5"; "+ T25"; "- T-25 L5 M-100" ]
         in
         assert_for_each_symbol [ 'A'; 'B'; 'C'; '+'; '-' ] expected_interp actual_interp
         )
       ; ("Systems.create_char_interp_from_str_list with duplicated symbols."
         >:: fun _ ->
         let expected_interp = function
           | 'A' -> [ Line 5; Turn (-30) ]
           | 'B' -> [ Turn 2; Line (-20) ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25); Line 5; Move (-100) ]
           | _ -> [ default_command ]
         in
         let actual_interp =
           create_char_interp_from_str_list
             [ "A L5 T-30"; "B L5"; "+ T25"; "- T-25 L5 M-100"; "B T2 L-20" ]
         in
         assert_for_each_symbol [ 'A'; 'B'; 'C'; '+'; '-' ] expected_interp actual_interp
         )
       ; ("Systems.create_char_interp_from_str_list with brackets."
         >:: fun _ ->
         let expected_interp = function
           | 'A' -> [ Line 5; Turn (-30) ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25); Line 5; Move (-100) ]
           | '[' -> [ Store ]
           | ']' -> [ Restore ]
           | _ -> [ default_command ]
         in
         let actual_interp =
           create_char_interp_from_str_list [ "A L5 T-30"; "+ T25"; "- T-25 L5 M-100" ]
         in
         assert_for_each_symbol
           [ 'A'; 'C'; '+'; '-'; '['; ']' ]
           expected_interp
           actual_interp)
       ; ("Systems.create_char_interp_from_str_list should raise Invalid_system with a \
           string starting with an invalid command init."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid interpretation ' L5'") (fun () ->
             create_char_interp_from_str_list [ "A L5 T-30"; " L5" ]))
       ; ("Systems.create_char_interp_from_str_list should raise Invalid_system with a a \
           string has invalid value."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid command 'T-s0'") (fun () ->
             create_char_interp_from_str_list [ "A L5 T-s0"; "B L5" ]))
       ; ("Systems.create_char_interp_from_str_list should raise Invalid_system with a a \
           string has no value."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid interpretation 'A '") (fun () ->
             create_char_interp_from_str_list [ "A "; "B L5" ]))
         (*(*  (**)*)

       (*     Systems.create_char_system_from_file tests related.*)

        *)
       ; ("Systems.create_system_from_file with br3.sys should create a valid \
           corresponding char system."
         >:: fun _ ->
         let system = create_system_from_file "../../../test/resources/br3.sys" in
         (* Verify system.axiom. *)
         let expected_axiom = Symb 'A' in
         assert_equal expected_axiom system.axiom;
         (* Verify system.rules. *)
         let expected_rules = function
           | 'A' ->
             Seq
               [ Symb 'B'
               ; Branch (Seq [ Symb '+'; Symb 'A' ])
               ; Branch (Seq [ Symb '-'; Symb 'A' ])
               ; Symb 'B'
               ; Symb 'A'
               ]
           | 'B' -> Seq [ Symb 'B'; Symb 'B' ]
           | s -> Symb s
         in
         assert_for_each_symbol [ 'A'; 'B' ] expected_rules system.rules;
         (* Verify system.interp. *)
         let expected_interp = function
           | 'A' -> [ Line 5 ]
           | 'B' -> [ Line 5 ]
           | '+' -> [ Turn 25 ]
           | '-' -> [ Turn (-25) ]
           | _ -> [ default_command ]
         in
         assert_for_each_symbol [ 'A'; 'B'; '+'; '-' ] expected_interp system.interp)
       ; ("Systems.create_system_from_file with htree.sys should create a valid char \
           system."
         >:: fun _ ->
         let system = create_system_from_file "../../../test/resources/htree.sys" in
         (* Verify system.axiom. *)
         let expected_axiom = Symb 'A' in
         assert_equal expected_axiom system.axiom;
         (* Verify system.rules. *)
         let expected_rules = function
           | 'A' ->
             Seq [ Symb 'B'; Branch (Seq [ Symb '+'; Symb 'A' ]); Symb '-'; Symb 'A' ]
           | 'B' -> Seq [ Symb 'C'; Symb 'C' ]
           | 'C' -> Symb 'B'
           | s -> Symb s
         in
         assert_for_each_symbol [ 'A'; 'B'; 'C' ] expected_rules system.rules;
         (* Verify system.interp. *)
         let expected_interp = function
           | 'A' -> [ Line 10 ]
           | 'B' -> [ Line 14 ]
           | 'C' -> [ Line 10 ]
           | '+' -> [ Turn 90 ]
           | '-' -> [ Turn (-90) ]
           | _ -> [ default_command ]
         in
         assert_for_each_symbol [ 'A'; 'B'; 'C'; '+'; '-' ] expected_interp system.interp
         )
       ; ("Systems.create_system_from_file with snow.sys should create a valid char \
           system."
         >:: fun _ ->
         let system = create_system_from_file "../../../test/resources/snow.sys" in
         (* Verify system.axiom. *)
         let expected_axiom =
           Seq [ Symb 'A'; Symb '+'; Symb '+'; Symb 'A'; Symb '+'; Symb '+'; Symb 'A' ]
         in
         assert_equal expected_axiom system.axiom;
         (* Verify system.rules. *)
         let expected_rules = function
           | 'A' ->
             Seq
               [ Symb 'A'
               ; Symb '-'
               ; Symb 'A'
               ; Symb '+'
               ; Symb '+'
               ; Symb 'A'
               ; Symb '-'
               ; Symb 'A'
               ]
           | s -> Symb s
         in
         assert_for_each_symbol [ 'A'; '+'; '-' ] expected_rules system.rules;
         (* Verify system.interp. *)
         let expected_interp = function
           | 'A' -> [ Line 30 ]
           | '+' -> [ Turn 60 ]
           | '-' -> [ Turn (-60) ]
           | _ -> [ default_command ]
         in
         assert_for_each_symbol [ 'A'; '+'; '-' ] expected_interp system.interp)
       ; ("Systems.create_system_from_file with invalid-axiom.sys should raise an \
           Invalid_word exception."
         >:: fun _ ->
         assert_raises (Invalid_system "Unclosed branch in 'A++A[A'") (fun () ->
             create_system_from_file "../../../test/resources/invalid-axiom.sys"))
       ; ("Systems.create_system_from_file with invalid-rules.sys should raise an \
           Invalid_rule exception."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid rule 'A-A++A-A'") (fun () ->
             create_system_from_file "../../../test/resources/invalid-rules.sys"))
       ; ("Systems.create_system_from_file with invalid-rules-2.sys should raise an \
           Invalid_word exception."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid word 'A-A]+A-A'") (fun () ->
             create_system_from_file "../../../test/resources/invalid-rules-2.sys"))
       ; ("Systems.create_system_from_file with invalid-interp.sys should raise an \
           Invalid_interp exception."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid interpretation 'T60'") (fun () ->
             create_system_from_file "../../../test/resources/invalid-interp.sys"))
       ; ("Systems.create_system_from_file with invalid-command.sys should raise an \
           Invalid_interp exception."
         >:: fun _ ->
         assert_raises (Invalid_system "Invalid command 'T@'") (fun () ->
             create_system_from_file "../../../test/resources/invalid-command.sys"))
       ; (*

            Systems.apply_rules tests related.

        *)
         ("Systems.apply_rules should return the right word with a valid basic system."
         >:: fun _ ->
         let rules_symb = function
           | 'A' -> Seq [ Symb 'A'; Symb 'A'; Symb 'A' ]
           | s -> Symb s
         in
         let axiom_symb = Symb 'A' in
         (*test Symb for apply_rules*)
         let actual_word = apply_rules rules_symb axiom_symb in
         let expected_word = Seq [ Symb 'A'; Symb 'A'; Symb 'A' ] in
         assert_equal expected_word actual_word)
       ; ("Systems.apply_rules should return the right word with a system that contains \
           a seq inside a branch."
         >:: fun _ ->
         let rules_branch_seq = function
           | 'A' -> Branch (Seq [ Symb 'A'; Symb 'B' ])
           | 'B' -> Symb 'A'
           | s -> Symb s
         in
         let axiom_branch_seq = Branch (Seq [ Symb 'A'; Symb 'B' ]) in
         (*test Branch and Seq for apply_rules*)
         let actual_word = apply_rules rules_branch_seq axiom_branch_seq in
         let expected_word =
           Branch (Seq [ Branch (Seq [ Symb 'A'; Symb 'B' ]); Symb 'A' ])
         in
         assert_equal expected_word actual_word)
       ; ("Systems.apply_rules should return the right word with a system that contains \
           a branches inside a seq."
         >:: fun _ ->
         let rules_seq_branch = function
           | 'A' -> Branch (Seq [ Symb 'A'; Symb 'B' ])
           | 'B' -> Symb 'A'
           | s -> Symb s
         in
         let axiom_seq_branch = Seq [ Branch (Seq [ Symb 'A'; Symb 'B' ]); Symb 'B' ] in
         (*test Branch and Seq for apply_rules*)
         let actual_word = apply_rules rules_seq_branch axiom_seq_branch in
         let expected_word =
           Seq
             [ Branch (Seq [ Branch (Seq [ Symb 'A'; Symb 'B' ]); Symb 'A' ]); Symb 'A' ]
         in
         assert_equal expected_word actual_word)
       ; ("Systems.apply_rules should return the right word empty."
         >:: fun _ ->
         let rules_empty = function
           | 'A' -> Branch (Seq [ Symb 'A'; Symb 'B' ])
           | 'B' -> Symb 'A'
           | s -> Symb s
         in
         let axiom_empty = Seq [] in
         (*test Empty word for apply_rules*)
         let actual_word = apply_rules rules_empty axiom_empty in
         let expected_word = Seq [] in
         assert_equal expected_word actual_word)
       ]
;;

let () = run_test_tt_main systems_suite
