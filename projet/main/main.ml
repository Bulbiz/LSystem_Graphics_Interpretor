open Printf
open Bimage
open Graphics
open Lsystems.Systems
open Lsystems.Turtle

let nb_step_ref = ref (-1)
let color_is_set_ref = ref false
let verbose_ref = ref false
let src_file_ref = ref ""
let dest_file_ref = ref ""
let width_ref = ref 400
let height_ref = ref 400

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

let wait_next_event () = ignore (wait_next_event [ Button_down; Key_pressed ])

let init_graph () =
  " " ^ string_of_int !width_ref ^ "x" ^ string_of_int !height_ref |> open_graph;
  wait_next_event ()
;;

(* Save the actual graph content into an png at [dest_file_ref]. *)
let save_image () =
  (* Gets the corresponding 3D matrix. *)
  let img_matrix = get_image 0 0 !width_ref !height_ref |> dump_image in
  (* Creates an empty image. *)
  let img = Image.create u8 gray !width_ref !height_ref in
  (* Fills the image with the content of [img_matrix]. *)
  Image.for_each (fun x y _ -> Image.set img x y 0 img_matrix.(y).(x)) img;
  (* Save the current [img] to the [dest_file_ref]. *)
  Bimage_unix.Magick.write !dest_file_ref img;
  if !verbose_ref then printf "[INFO] : Image saved to '%s'\n" !dest_file_ref
;;

let update_current_word current_step_nb =
  if !verbose_ref
  then (
    printf "[INFO] : n = %d, current_word = '" current_step_nb;
    print_char_word !current_word_ref;
    print_endline "'");
  current_word_ref := apply_rules !systems_ref.rules !current_word_ref
;;

let interpret_current_word ()=
  modify_initial_position ((float_of_int !width_ref) /. 2.) ((float_of_int !height_ref) /. 2.) 0;
  set_line_width 5;
  interpret_word !systems_ref.interp !current_word_ref

let main () =
  Arg.parse (Arg.align cmdline_options) extra_arg_action usage_msg;
  if is_valid_args ()
  then (
    if !verbose_ref then print_current_state ();
    (* Try to creates a char system from `src_file_ref`. *)
    try
      systems_ref := create_system_from_file !src_file_ref;
      if !verbose_ref then print_endline "[INFO] : L-System created";
      current_word_ref := !systems_ref.axiom;
      (* Creates a graph. *)
      init_graph ();
      for i = 0 to !nb_step_ref do
        update_current_word i;
        Unix.sleep 1;
        (* TODO: updates the graph. *)
        (*let x = i * 20 in*)
        interpret_current_word ();
        (*fill_rect x x 20 20;*)
        synchronize ()
      done;
      wait_next_event ();
      if "" <> !dest_file_ref then save_image ()
    with
    | Invalid_system msg -> print_endline msg
    | Sys_error msg -> print_endline ("[ERROR] " ^ msg))
;;

let () = if not !Sys.interactive then main ()
