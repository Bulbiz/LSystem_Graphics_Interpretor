open Printf
open Lsystems.Systems

let nb_step_ref = ref (-1)
let color_is_set_ref = ref false
let verbose_ref = ref false
let src_file_ref = ref ""
let dest_file_ref = ref ""

let systems_ref =
  ref { axiom = empty_word; rules = (fun _ -> empty_word); interp = default_interp }
;;

let current_word_ref = ref empty_word

(* Usages message. *)
let usage_msg =
  "Usage: \n ./run.sh -n nb_step -f sys_file [-c] [-o output] [--verbose]\n\n"
  ^ "Needed: \n"
  ^ " -f    \tInput file where is described the L-System\n"
  ^ " -n    \tThe number of interpretation steps\n\n"
  ^ "Options:"
;;

let set_color () = color_is_set_ref := true
let set_verbose () = verbose_ref := true
let set_max_step max_step = nb_step_ref := max_step
let set_output_file dest_file = dest_file_ref := dest_file
let set_input_file input_file = src_file_ref := input_file

let cmdline_options =
  [ "-c", Arg.Unit set_color, "\tRender with colors"
  ; ( "-o"
    , Arg.String set_output_file
    , "\tThe output file where final image will be saved to" )
  ; "--verbose", Arg.Unit set_verbose, ""
  ; "-n", Arg.Int set_max_step, ""
  ; "-f", Arg.String set_input_file, ""
  ]
;;

let extra_arg_action s = failwith ("Invalid option : " ^ s)

(* Verifies that all needed argument are provided. *)
let is_valid_args () =
  if -1 = !nb_step_ref
  then
    print_endline
      "[ERROR in arguments] : The number of step needs to be specified. (--help for more \
       informations)";
  if "" = !src_file_ref
  then
    print_endline
      "[ERROR in arguments] : The source file needs to be specified. (--help for more \
       informations)";
  -1 <> !nb_step_ref && "" <> !src_file_ref
;;

let print_current_state () =
  printf "[INFO] : Color       = '%b'\n" !color_is_set_ref;
  printf "[INFO] : Src file    = '%s'\n" !src_file_ref;
  printf "[INFO] : Dest file   = '%s'\n" !dest_file_ref;
  printf "[INFO] : Nb of steps = %d\n" !nb_step_ref
;;

let main () =
  Arg.parse (Arg.align cmdline_options) extra_arg_action usage_msg;
  if is_valid_args ()
  then (
    if !verbose_ref then print_current_state ();
    (* Try to creates a char system from `src_file_ref`. *)
    try
      systems_ref := create_system_from_file !src_file_ref;
      if !verbose_ref then print_endline "[INFO] : L-System created.";
      current_word_ref := !systems_ref.axiom;
      for i = 0 to !nb_step_ref do
        if !verbose_ref
        then (
          printf "[INFO] : n = %d, current_word = '" i;
          print_char_word !current_word_ref;
          print_endline "'");
        current_word_ref := apply_rules !systems_ref.rules !current_word_ref
        (*TODO: Update graphics. *)
      done
      (*TODO: Save images. *)
    with
    | Invalid_system msg -> print_endline msg
    | Sys_error msg -> print_endline ("[ERROR] " ^ msg))
;;

let () = if not !Sys.interactive then main ()
