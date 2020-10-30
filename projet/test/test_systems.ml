open OUnit2
open Lsystems

let systems_suite =
    "SystemsTestSuite" >::: [
        "Systems.return_0 should return 0" >:: (fun _ ->
            assert_equal 0 Systems.return_0
        );
        "Systems.f_do_nothing should print" >:: (fun _ ->
            assert_equal "Test string" Systems.return_str
        )
    ]

let () = run_test_tt_main systems_suite
