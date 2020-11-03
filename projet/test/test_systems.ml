open OUnit2
open Lsystems
open Systems

type symbol = A

let test : symbol system = 
    {
    axiom = Seq [Symb A];
    rules = (function
    | A -> Seq [Symb A;Symb A;Symb A]
    );

    interp = (function
    | A -> [Line 30])
    }

let testUpdate = update test 
let expectedUpdate = Seq [Symb A;Symb A;Symb A]

let systems_suite =
    "SystemsTestSuite" >::: [
        "Systems Update should return Seq[Symb A,Symb A]" >:: (fun _ ->
            assert_equal testUpdate expectedUpdate
        );

        "Systems.f_do_nothing should print" >:: (fun _ ->
            assert_equal "Test string" Systems.return_str
        )
    ]

let () = run_test_tt_main systems_suite
