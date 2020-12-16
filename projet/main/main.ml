open Graphics
open Limage
open Lsystems.Systems
open Lsystems.Turtle
open Printf

(** Parameters. *)

let color_is_set_ref = ref false
let verbose_ref = ref false
let src_file_ref = ref ""
let dest_file_ref = ref ""
let init_xpos_ref = ref 0.5
let init_ypos_ref = ref 0.10
let margin = 15.
let shift_ref = ref 0.0

let systems_ref =
  ref { axiom = empty_word; rules = (fun _ -> empty_word); interp = default_interp }
;;

let current_word_ref = ref empty_word
let current_depth = ref 0

(* Usages message. *)
let usage_msg =
  "Usage: \n ./run.sh -f sys_file [ options ]\n\n"
  ^ "Needed: \n"
  ^ " -f    \tInput file where is described the L-System\n\n"
  ^ "Options:"
;;

let set_verbose () = verbose_ref := true
let set_output_file dest_file = dest_file_ref := dest_file
let set_input_file input_file = src_file_ref := input_file
let set_shift_value value = shift_ref := float_of_int value
let set_color () = color_is_set_ref := true

let set_init_pos = function
  | "center" -> init_ypos_ref := 0.5
  | "center-left" ->
    init_ypos_ref := 0.5;
    init_xpos_ref := 0.15
  | "center-right" ->
    init_ypos_ref := 0.5;
    init_xpos_ref := 0.75
  | "bottom-left" -> init_xpos_ref := 0.15
  | "bottom-right" -> init_xpos_ref := 0.75
  | "top" -> init_ypos_ref := 0.8
  | "top-left" ->
    init_xpos_ref := 0.15;
    init_ypos_ref := 0.8
  | "top-right" ->
    init_xpos_ref := 0.75;
    init_ypos_ref := 0.8
  | "bottom" -> ()
  | s -> raise (Arg.Bad ("[ERROR] : '" ^ s ^ "' is not a valid starting position."))
;;

let cmdline_options =
  [ "-c", Arg.Unit set_color, "\tRender with colors"
  ; "--color=", Arg.String set_color_interpretation, "Color, choose between [red,blue,green,magenta,cyan,yellow]"
  ; ( "-s"
    , Arg.Int set_shift_value
    , "\tValue for the aleatory shifting in the interpretation" )
  ; ( "-o"
    , Arg.String set_output_file
    , "\tThe output file where final image will be saved to" )
  ; ( "--start-pos"
    , Arg.String set_init_pos
    , "\tThe starting position accepted values :\n\
       \t\tcenter, bottom, top, center-left, center-right, bottom-left, bottom-right, \
       top-left, top-right (default: bottom)\n" )
  ; "--verbose", Arg.Unit set_verbose, ""
  ; "-f", Arg.String set_input_file, ""
  ]
;;

let extra_arg_action s = failwith ("Invalid option : " ^ s)

(* Verifies that all needed argument are provided. *)
let is_valid_args () =
  if "" = !src_file_ref
  then
    print_endline
      "[ERROR in arguments] : The source file needs to be specified. (--help for more \
       informations)";
  if 0.0 > !shift_ref
  then
    print_endline
      "[ERROR in arguments] : The shifting value has to be positive. (--help for more \
       informations)";
  "" <> !src_file_ref && 0.0 <= !shift_ref
;;

let print_current_state () =
  printf "[INFO] - Color       = '%b'\n" !color_is_set_ref;
  printf "[INFO] - Shifting    = '%f'\n" !shift_ref;
  printf "[INFO] - Src file    = '%s'\n" !src_file_ref;
  printf "[INFO] - Dest file   = '%s'\n" !dest_file_ref
;;

let init_graph () =
  " " ^ string_of_int 700 ^ "x" ^ string_of_int 700 |> open_graph;
  Graphics.set_color (rgb 150 150 150);
  set_line_width 1
;;

(* Applies system's rules to the current word and returns it. *)
let update_current_word current_step_nb =
  if !verbose_ref
  then (
    printf "[INFO] - n = %d, current_word = '" current_step_nb;
    print_char_word !current_word_ref;
    print_endline "'");
  current_word_ref := apply_rules !systems_ref.rules !current_word_ref
;;

let reset_initial_position () =
  modify_initial_position
    (float_of_int (size_x ()) *. !init_xpos_ref)
    (float_of_int (size_y ()) *. !init_ypos_ref)
    90
;;

(* Finds the right scaling ratio to fit the entire draw in the window. *)
let calc_scaling_coef () =
  let max_height = float_of_int (size_x ()) -. margin in
  let max_width = float_of_int (size_y ()) -. margin in
  while
    draw_boundary.top > max_height
    || draw_boundary.bottom < margin
    || draw_boundary.right > max_width
    || draw_boundary.left < margin
  do
    reset_draw_boundary ();
    reset_initial_position ();
    scale_coef_ref := !scale_coef_ref *. 0.8;
    interpret_word !systems_ref.interp !current_word_ref false false
  done
;;

(* Resets init pos and apply system's interpretations to the current word. *)
let interpret_current_word () =
  clear_graph ();
  interpret_word !systems_ref.interp !current_word_ref false false;
  calc_scaling_coef ();
  reset_initial_position ();
  reset_current_depth ();
  reset_color ();
  interpret_word !systems_ref.interp !current_word_ref !color_is_set_ref true
;;

let reset_current_word () = current_word_ref := !systems_ref.axiom
let reset_scale_coef () = scale_coef_ref := 35.

let calculate_depth n =
  if n >= 0
  then (
    reset_current_word ();
    reset_scale_coef ();
    for i = 0 to n - 1 do
      update_current_word i
    done;
    interpret_current_word ();
    synchronize ();
    current_depth := n)
;;

let calculate_next_depth () =
  current_depth := !current_depth + 1;
  reset_scale_coef ();
  update_current_word !current_depth;
  interpret_current_word ();
  synchronize ()
;;

let rec user_action () =
  let user_input = Graphics.wait_next_event [ Graphics.Key_pressed ] in
  match user_input.key with
  | 'a' | 'l' | 'j' ->
    calculate_next_depth ();
    user_action ()
  | 'r' | 'h' | 'k' ->
    calculate_depth (!current_depth - 1);
    user_action ()
  | 's' ->
    if "" <> !dest_file_ref
    then (
      Png.save_grey !dest_file_ref;
      print_endline
        ("[INFO] - Saving PNG image at '"
        ^ !dest_file_ref
        ^ "' the iteration "
        ^ string_of_int !current_depth));
    user_action ()
  | _ -> ()
;;

let main () =
  Arg.parse (Arg.align cmdline_options) extra_arg_action usage_msg;
  if is_valid_args ()
  then (
    if !verbose_ref then print_current_state ();
    (* Tries to creates a char system from `src_file_ref`. *)
    try
      systems_ref := create_system_from_file !src_file_ref;
      if !verbose_ref then print_endline "[INFO] : L-System created";
      current_word_ref := !systems_ref.axiom;
      reset_current_word ();
      (* Set up the random shifting *)
      Random.self_init ();
      set_shifting !shift_ref;
      (* Creates a graph. *)
      init_graph ();
      interpret_current_word ();
      (* Wait the user input *)
      user_action ()
    with
    | Sys_error msg | Invalid_system msg -> print_endline ("[ERROR] : " ^ msg))
;;

let () = if not !Sys.interactive then main ()
