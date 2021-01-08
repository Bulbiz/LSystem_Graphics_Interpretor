open Graphics
open Limage
open Lsystems.Systems
open Lsystems.Turtle
open Printf

(** Parameters.
 * These variables are ref because they have to be initialised (by Arg.parse).
 *)

let color_is_set_ref = ref false
let verbose_ref = ref false
let line_width_ref = ref 1
let src_file_ref = ref ""
let dest_file_ref = ref ""
let init_xpos_ref = ref 0.5
let init_ypos_ref = ref 0.10
let margin = 15.
let shift_ref = ref 0.0

(** Is the current loaded systems. *)
let systems_ref =
  ref { axiom = empty_word; rules = (fun _ -> empty_word); interp = default_interp }
;;

(* Usages message. *)
let usage_msg =
  "Usage: \n\t\t./run.sh -f sys_file [ options ]\n\n"
  ^ "Needed: \n"
  ^ "  -f\t\tInput file where the L-System is described\n\n"
  ^ "Options:"
;;

(** Setters used from args. *)

let set_verbose () = verbose_ref := true
let set_output_file dest_file = dest_file_ref := dest_file
let set_input_file input_file = src_file_ref := input_file
let set_shift_value value = shift_ref := float_of_int value
let set_line_width_ref line_width = line_width_ref := line_width

let set_color color =
  color_is_set_ref := true;
  set_color_interpretation color
;;

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
  [ ( "-s"
    , Arg.Int set_shift_value
    , "\tValue for the aleatory shifting in the interpretation" )
  ; ( "-o"
    , Arg.String set_output_file
    , "\tThe output file where final image will be saved to" )
  ; ( "--line-width"
    , Arg.Int set_line_width_ref
    , "\tPositive integer used for initialized the line width" )
  ; ( "--color"
    , Arg.String set_color
    , "\tRendering color accepted values :\n\
       \t\t  red, blue, green, magenta, cyan, yellow, (default: grey)" )
  ; ( "--start-pos"
    , Arg.String set_init_pos
    , "\tStarting position accepted values :\n\
       \t\t  center, bottom, top, center-left, center-right, bottom-left, bottom-right, \
       top-left, top-right (default: bottom)\n" )
  ; "--verbose", Arg.Unit set_verbose, ""
  ; "-f", Arg.String set_input_file, ""
  ]
;;

let extra_arg_action s = failwith ("Invalid option : " ^ s)

(* Verifies that all needed argument are provided and valid. *)
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
  if 0 > !line_width_ref
  then
    print_endline
      "[ERROR in arguments] : The line width value has to be positive. (--help for more \
       informations)";
  "" <> !src_file_ref && 0.0 <= !shift_ref && 0 <= !line_width_ref
;;

(* Printed if the option [--verbose] is provided. *)
let print_current_state () =
  printf "[INFO] - Color       = '%b'\n" !color_is_set_ref;
  printf "[INFO] - Shifting    = '%f'\n" !shift_ref;
  printf "[INFO] - Src file    = '%s'\n" !src_file_ref;
  printf "[INFO] - Dest file   = '%s'\n" !dest_file_ref
;;

(* Inits the [Graphics] graph with its default values. *)
let init_graph () =
  " " ^ string_of_int 700 ^ "x" ^ string_of_int 700 |> open_graph;
  Graphics.set_color (rgb 150 150 150);
  set_line_width !line_width_ref
;;

(* Applies system's rules to the current word and returns it. *)
let update_current_word word current_step_nb =
  if !verbose_ref
  then (
    printf "[INFO] - n = %d, current_word = '" current_step_nb;
    print_char_word word;
    print_endline "'");
  apply_rules !systems_ref.rules word
;;

(* Resets initial starting position. *)
let reset_initial_position () =
  modify_initial_position
    (float_of_int (size_x ()) *. !init_xpos_ref)
    (float_of_int (size_y ()) *. !init_ypos_ref)
    90
;;

(* Finds the right scaling ratio to fit the entire draw in the window. *)
let rec calc_scaling_coef word max_width max_height =
  if draw_boundary.top > max_height
     || draw_boundary.bottom < margin
     || draw_boundary.right > max_width
     || draw_boundary.left < margin
  then (
    reset_draw_boundary ();
    reset_initial_position ();
    scale_coef_ref := !scale_coef_ref *. 0.8;
    interpret_word !systems_ref.interp word false false 0;
    calc_scaling_coef word max_width max_height)
;;

(* Resets init pos and apply system's interpretations to the current word. *)
let interpret_current_word word =
  clear_graph ();
  interpret_word !systems_ref.interp word false false 0;
  calc_scaling_coef
    word
    (float_of_int (size_x ()) -. margin)
    (float_of_int (size_y ()) -. margin);
  reset_initial_position ();
  reset_color ();
  interpret_word !systems_ref.interp word !color_is_set_ref true 0
;;

let get_axiom () = !systems_ref.axiom
let reset_scale_coef () = scale_coef_ref := 35.

let rec update_word_n_time word n =
  let word = update_current_word word n in
  if 0 < n then update_word_n_time word (n - 1) else word
;;

let calculate_to_iteration n =
  if n >= 0
  then (
    let word = get_axiom () in
    reset_scale_coef ();
    let new_word = update_word_n_time word (n - 1) in
    interpret_current_word new_word;
    synchronize ())
;;

(* Updates the [current_word_ref] one time before interpreting it. *)
let calculate_next_iteration word nb_iteration =
  let nb_iteration = nb_iteration + 1 in
  reset_scale_coef ();
  let new_word = update_current_word word nb_iteration in
  interpret_current_word new_word;
  synchronize ();
  new_word, nb_iteration
;;

(* Binds keys to user actions. *)
let rec user_action nb_iteration word =
  let user_input = Graphics.wait_next_event [ Graphics.Key_pressed ] in
  match user_input.key with
  | 'a' | 'l' | 'j' ->
    let new_word, new_iteration = calculate_next_iteration word nb_iteration in
    user_action new_iteration new_word
  | 'r' | 'h' | 'k' ->
    let nb_iteration = nb_iteration - 1 in
    calculate_to_iteration nb_iteration;
    user_action nb_iteration word
  | 's' ->
    if "" <> !dest_file_ref
    then (
      Png.save_to !dest_file_ref;
      print_endline
        ("[INFO] - Saving PNG image at '"
        ^ !dest_file_ref
        ^ "' the iteration "
        ^ string_of_int nb_iteration));
    user_action nb_iteration word
  | _ -> word
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
      (* Set up the random shifting *)
      Random.self_init ();
      set_shifting !shift_ref;
      (* Creates a graph. *)
      init_graph ();
      (* Wait the user input *)
      let _ = user_action 0 (get_axiom ()) in
      ()
    with
    | Sys_error msg | Invalid_system msg -> print_endline ("[ERROR] : " ^ msg))
;;

let () = if not !Sys.interactive then main ()
