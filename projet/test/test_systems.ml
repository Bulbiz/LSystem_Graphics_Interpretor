open OUnit2
open Lsystems
open Systems
(*
let test1 : char system = 
    {
        axiom = Seq [Symb 'A'];
        rules = (function
        | 'A' -> Seq [Symb 'A';Symb 'A';Symb 'A']
        | s -> Symb s
    );

    interp = (function
    | 'A' -> [Line 30]
    | _ -> [Turn 0])
    }

let test2 : char system = 
    {
        axiom = Seq [Symb 'A';Symb 'B'];
        rules = (function
        | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
        | 'B' -> Symb 'A'
        | s -> Symb s
    );
    
    interp = (function
    | 'A' -> [Line 30]
    | 'B' -> [Turn 60]
    | _ -> [Turn 0])
    }    
    *)
let systems_suite =
    "SystemsTestSuite" >::: [
        "TestSymb: Update should return Seq[Symb A,Symb A,Symb A]" >:: (fun _ ->
            let testSeq : char system = 
            {
                axiom = Symb 'A';
                rules = (function
                | 'A' -> Seq [Symb 'A';Symb 'A';Symb 'A']
                | s -> Symb s
            );
        
                interp = (function
                | 'A' -> [Line 30]
                | _ -> [Turn 0])
            }in
            (*test 1 for update*)
            let test_next_state1 = next_state testSeq.rules testSeq.axiom in
            let expected_next_state1 = Seq [Symb 'A';Symb 'A';Symb 'A'] in
            assert_equal test_next_state1  expected_next_state1 ;
        );

        "TestBranch: Update should return Seq [Branch (Seq[Symb 'A';Symb 'B']);Symb 'A']" >:: (fun _ ->
            let testBranch : char system = 
            {
                axiom = Seq [Symb 'A';Symb 'B'];
                rules = (function
                | 'A' -> Branch (Seq[Symb 'A';Symb 'B'])
                | 'B' -> Symb 'A'
                | s -> Symb s
            );
            
                interp = (function
                | 'A' -> [Line 30]
                | 'B' -> [Turn 60]
                | _ -> [Turn 0])
            }  in
            (*test 2 for update*)
            let test_next_state2 = next_state testBranch.rules testBranch.axiom in
            let expected_next_state2 = Seq [Branch (Seq[Symb 'A';Symb 'B']);Symb 'A'] in
            assert_equal test_next_state2 expected_next_state2 
        )
    ]

let () = run_test_tt_main systems_suite
