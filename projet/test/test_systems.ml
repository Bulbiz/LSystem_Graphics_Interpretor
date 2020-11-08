open OUnit2
open Lsystems
open Systems

let systems_suite =
    "SystemsTestSuite" >::: [
        "Systems.next_state should return the right word with a valid basic system." >:: (fun _ ->
            let rules_symb : char rewrite_rules = (function
                | 'A' -> Seq [Symb 'A';Symb 'A';Symb 'A']
                | s -> Symb s)
            in 
            let axiom_symb = Symb 'A' in
            (*test Symb for next_state*)
            let actual_word = next_state rules_symb axiom_symb in
            let expected_word = Seq [Symb 'A';Symb 'A';Symb 'A'] in
            assert_equal expected_word actual_word;
        );


        "Systems.next_state should return the right word with a system that contains a seq inside a branch." >:: (fun _ ->
            let rules_branch_seq = (function
                | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
                | 'B' -> Symb 'A'
                | s -> Symb s) 
            in 
            let axiom_branch_seq = Branch(Seq [Symb 'A';Symb 'B']) in

            (*test Branch and Seq for next_state*)
            let actual_word = next_state rules_branch_seq axiom_branch_seq in
            let expected_word = Branch(Seq [Branch (Seq[Symb 'A';Symb 'B']); Symb 'A']) in
            assert_equal expected_word actual_word
        );


        "Systems.next_state should return the right word with a system that contains a branches inside a seq." >:: (fun _ ->
            let rules_seq_branch = (function
                | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
                | 'B' -> Symb 'A'
                | s -> Symb s) 
            in 
            let axiom_seq_branch = Seq [Branch(Seq[Symb 'A';Symb 'B']); Symb 'B'] in

            (*test Branch and Seq for next_state*)
            let actual_word = next_state rules_seq_branch axiom_seq_branch in
            let expected_word = Seq[Branch(Seq [Branch (Seq[Symb 'A';Symb 'B']); Symb 'A']); Symb 'A'] in
            assert_equal expected_word actual_word
        );

        "Systems.next_state should return the right word empty." >:: (fun _ ->
            let rules_seq_branch = (function
                | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
                | 'B' -> Symb 'A'
                | s -> Symb s) 
            in 
            let axiom_seq_branch = Seq [] in

            (*test Branch and Seq for next_state*)
            let actual_word = next_state rules_seq_branch axiom_seq_branch in
            let expected_word = Seq[] in
            assert_equal expected_word actual_word
        );
    ]

let () = run_test_tt_main systems_suite
