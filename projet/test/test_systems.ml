open OUnit2
open Lsystems
open Systems

let systems_suite =
    "SystemsTestSuite" >::: [
        "TestSymb: Update should return Seq[Symb A,Symb A,Symb A]" >:: (fun _ ->
            let rules_symb : char rewrite_rules = (function
                | 'A' -> Seq [Symb 'A';Symb 'A';Symb 'A']
                | s -> Symb s)
            in 
            let axiom_symb : char word = Symb 'A' in
            (*test Symb for next_state*)
            let test_symb = next_state rules_symb axiom_symb in
            let expected_symb = Seq [Symb 'A';Symb 'A';Symb 'A'] in
            assert_equal test_symb  expected_symb ;
        );


        "TestBranch: Update should return Seq [Branch (Seq[Symb 'A';Symb 'B']);Symb 'A']" >:: (fun _ ->
            let rules_branch_seq : char rewrite_rules = (function
                | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
                | 'B' -> Symb 'A'
                | s -> Symb s) 
            in 
            let axiom_branch_seq : char word = Branch(Seq [Symb 'A';Symb 'B']) in

            (*test Branch and Seq for next_state*)
            let test_branch_seq = next_state rules_branch_seq axiom_branch_seq in
            let expected_branch_seq = Branch(Seq [Branch (Seq[Symb 'A';Symb 'B']); Symb 'A']) in
            assert_equal test_branch_seq expected_branch_seq 
        )
    ]

let () = run_test_tt_main systems_suite
