open OUnit2
open Lsystems.Systems

(* open Lsystems.Turtle *)

let assert_for_each_symbol s_list expected_rules actual_rules =
  List.iter (fun s -> assert_equal (expected_rules s) (actual_rules s)) s_list
;;

let systems_suite =
  "SystemsTestSuite"
  >::: [ ("Systems.create_char_word_from_str with one char"
         >:: fun _ -> assert_equal (Symb 'A') (create_char_word_from_str "A"))
       ; ("Systems.create_char_word_from_str with a normal word string"
         >:: fun _ ->
         assert_equal (Seq [ Symb 'A'; Symb 'B' ]) (create_char_word_from_str "AB"))
       ; ("Systems.create_char_word_from_str with a root branch based word"
         >:: fun _ ->
         assert_equal
           (Seq [ Branch (Seq [ Symb 'A'; Symb 'B' ]) ])
           (create_char_word_from_str "[AB]"))
       ; ("Systems.create_char_word_from_str with a normal branched string word"
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
       ; ("Systems.create_char_word_from_str with a double branched string word"
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
           word"
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
       ; ("Systems.create_rules_from_str with a simple string word"
         >:: fun _ ->
         let expected_rules = function
           | 'B' -> Seq [ Symb 'B'; Symb 'B' ]
           | s -> Symb s
         in
         let actual_rules = create_char_rules_from_str "B BB" in
         assert_for_each_symbol [ 'B'; '+' ] expected_rules actual_rules)
         (* ; ("Systems.create_system_from_file with br3.sys should create a valid char \ *)
       (*     system." *)
         (*   >:: fun _ -> *)
         (*   let system = create_system_from_file "../../../test/resources/br3.sys" in *)
         (*   (* Verify system.axiom. *) *)
         (*   let expected_axiom = Symb 'A' in *)
         (*   assert_equal expected_axiom system.axiom; *)
         (*   (* Verify system.rules. *) *)
         (*   let expected_rules = function *)
         (*     | 'A' -> *)
         (*     | 'B' -> Seq [ Symb 'B'; Symb 'B' ] *)
         (*     | s -> Symb s *)
         (*   in *)
         (*   assert_for_each_symbol [ 'A'; 'B' ] expected_rules system.rules *)
         (*   (* (* Verify system.interp. *) *) *)
         (*   (* let expected_interp = function *) *)
         (*   (*   | 'A' | 'B' -> [ Line 5 ] *) *)
         (*   (*   | '+' -> [ Turn 25 ] *) *)
         (*   (*   | '-' -> [ Turn (-25) ] *) *)
         (*   (*   | _ -> [ default_command ] *) *)
         (*   (* in *) *)
         (*   (* assert_for_each_symbol [ 'A'; 'B'; '+'; '-' ] expected_interp system.interp *) *)
         (*   ) *)
       ]
;;

let () = run_test_tt_main systems_suite
