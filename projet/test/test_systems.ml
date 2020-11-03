open OUnit2
open Lsystems
open Systems

type symbol = A|B|C|D 
let test1 : symbol system = 
    {
        axiom = Seq [Symb A];
        rules = (function
        | A -> Seq [Symb A;Symb A;Symb A]
        | s -> Symb s
    );

    interp = (function
    | A -> [Line 30]
    | _ -> [Turn 0])
    }

let test2 : symbol system = 
    {
        axiom = Seq [Symb A;Symb B];
        rules = (function
        | A -> Seq [Symb A;Symb B]
        | B -> Symb A
        | s -> Symb s
    );
    
    interp = (function
    | A -> [Line 30]
    | B -> [Turn 60]
    | _ -> [Turn 0])
    }    
    
let systems_suite =
    "SystemsTestSuite" >::: [
        "Systems Update should return Seq[Symb A,Symb A,Symb A]" >:: (fun _ ->
            (*test 1 for update*)
            let testUpdate1 = update test1 in
            let expectedUpdate1 = Seq [Symb A;Symb A;Symb A] in
            assert_equal testUpdate1 expectedUpdate1;
        );

        "Systems Update should return Seq[Symb A,Symb B,Symb A]" >:: (fun _ ->
            (*test 2 for update*)
            let testUpdate2 = update test2 in
            let expectedUpdate2 = Seq [Seq[Symb A;Symb B];Symb A] in
            assert_equal testUpdate2 expectedUpdate2
        )
    ]

let () = run_test_tt_main systems_suite
