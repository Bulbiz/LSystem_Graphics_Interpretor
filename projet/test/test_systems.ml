open OUnit2
open Lsystems.Systems
open Lsystems.Turtle

let systems_suite =
    "SystemsTestSuite" >::: [
        "test create_system_from_file with br3.sys" >:: (fun _ ->
            let system = create_system_from_file "resources/br3.sys" in
            (* Verify system.axiom. *)
            let expected_axiom = Symb 'A' in
            assert_equal expected_axiom system.axiom;

            (* Verify system.rules. *)
            let expected_A_rewrited =
                Seq [ Symb 'B';
                        Branch(Seq [Symb '+'; Symb 'A']);
                        Branch(Seq [Symb '-'; Symb 'A']);
                        Symb 'B';
                        Symb 'A'
                ]
            in
            let expected_B_rewrited = Seq [Symb 'B'; Symb 'B'] in
            assert_equal expected_A_rewrited (system.rules 'A');
            assert_equal expected_B_rewrited (system.rules 'B');

            (* Verify system.interp. *)
            let expected_A_interp = Line 5 in
            let expected_B_interp = Line 5 in
            let expected_plus_interp = Turn 25 in
            let expected_minus_interp = Turn (-25) in
            assert_equal expected_A_interp (List.hd (system.interp 'A'));
            assert_equal expected_B_interp (List.hd (system.interp 'B'));
            assert_equal expected_plus_interp (List.hd (system.interp '+'));
            assert_equal expected_minus_interp (List.hd (system.interp '-'));
        );
    ]

let () = run_test_tt_main systems_suite
