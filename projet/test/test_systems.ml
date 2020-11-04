open OUnit2
open Lsystems
open Systems

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
        | 'A' -> Seq [Symb 'A';Symb 'B']
        | 'B' -> Symb 'A'
        | s -> Symb s
    );
    
    interp = (function
    | 'A' -> [Line 30]
    | 'B' -> [Turn 60]
    | _ -> [Turn 0])
    }    
    
let systems_suite =
    "SystemsTestSuite" >::: [
        "Test1: Update should return Seq[Symb A,Symb A,Symb A]" >:: (fun _ ->
            (*test 1 for update*)
            let test_update1 = update test1 in
            let expected_update1 = Seq [Symb 'A';Symb 'A';Symb 'A'] in
            assert_equal test_update1 expected_update1;
        );

        "Test2 Update should return Seq [Symb A; Symb B ; Symb A]" >:: (fun _ ->
            (*test 2 for update*)
            let test_update2 = update test2 in
            let expected_update2 = Seq [Seq [Symb 'A'; Symb 'B']; Symb 'A'] in
            assert_equal test_update2 expected_update2
        )
    ]

let () = run_test_tt_main systems_suite
