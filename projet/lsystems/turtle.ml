open Graphics

type command =
  | Line of int
  | Move of int
  | Turn of int
  | Store
  | Restore

type position =
  { x : float (** position x *)
  ; y : float (** position y *)
  ; a : int (** angle of the direction *)
  }

type draw_boundary =
  { mutable top : float
  ; mutable right : float
  ; mutable bottom : float
  ; mutable left : float
  }

type color_rgb =
  { mutable r : int
  ; mutable g : int
  ; mutable b : int
  }

(** Type for the color value, the order is (red,green,blue). *)
type color_value = Color of bool * bool * bool

let scale_coef_ref = ref 35.
let default_command = Turn 0
let initial_position = { x = 0.; y = 0.; a = 0 }
let storage = Stack.create ()
let current_position = ref initial_position
let draw_boundary = { top = 0.; right = 0.; bottom = 0.; left = 0. }
let shift = ref 1.0
let set_shifting shift_value = shift := shift_value
let current_color = { r = 10; g = 10; b = 10 }
let color_ref = ref (Color (true, true, true))

let get_shift () =
  let shift_value = Random.float !shift in
  if Random.bool () then -1. *. shift_value else shift_value
;;

let reset_draw_boundary () =
  draw_boundary.top <- 0.;
  draw_boundary.right <- 0.;
  draw_boundary.bottom <- 0.;
  draw_boundary.left <- 0.
;;

let reset_color () =
  current_color.r <- 10;
  current_color.g <- 10;
  current_color.b <- 10
;;

let modify_initial_position initial_x initial_y initial_a =
  current_position := { x = initial_x; y = initial_y; a = initial_a };
  moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

let convert_degree_to_radian angle = angle *. (Float.pi /. 180.)

let update_current_position len a =
  let angle =
    convert_degree_to_radian (float_of_int !current_position.a +. get_shift ())
  in
  let new_x = !current_position.x +. (cos angle *. len) in
  let new_y = !current_position.y +. (sin angle *. len) in
  let new_a = !current_position.a + a in
  current_position := { x = new_x; y = new_y; a = new_a }
;;

let update_draw_limits curr_x curr_y =
  if curr_y > draw_boundary.top || 0. = draw_boundary.top then draw_boundary.top <- curr_y;
  if curr_x > draw_boundary.right || 0. = draw_boundary.right
  then draw_boundary.right <- curr_x;
  if curr_y < draw_boundary.bottom || 0. = draw_boundary.bottom
  then draw_boundary.bottom <- curr_y;
  if curr_x < draw_boundary.left || 0. = draw_boundary.left
  then draw_boundary.left <- curr_x
;;

let update_state len a =
  update_current_position len a;
  update_draw_limits !current_position.x !current_position.y
;;

let interpret_line len draw =
  update_state len 0;
  if draw
  then lineto (int_of_float !current_position.x) (int_of_float !current_position.y)
  else moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

let interpret_move len =
  update_state len 0;
  moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

let interpret_turn a = update_state 0. a

(** Set the [color_ref] according the arg color. *)
let set_color_interpretation color =
  match color with
  | "red" -> color_ref := Color (true, false, false)
  | "blue" -> color_ref := Color (false, false, true)
  | "green" -> color_ref := Color (false, true, false)
  | "magenta" -> color_ref := Color (true, false, true)
  | "cyan" -> color_ref := Color (false, true, true)
  | "yellow" -> color_ref := Color (true, true, false)
  | _ -> color_ref := Color (true, true, true)
;;

(* Constant values used for calculates the new [current_color]. *)
let max_color_value = 255
let gradient_shift = 50

(* Calculates the new [current_color]. *)
let calc_new_color color_value gradient_coef =
  max_color_value - (color_value * gradient_coef)
;;

(** Updates the current color for the interpretation according the current depth. *)
let update_color depth =
  match !color_ref with
  | Color (red, green, blue) ->
    (* Calculates the constant. *)
    let gradient_coef =
      depth / (int_of_float !scale_coef_ref + gradient_shift) mod max_color_value
    in
    (* Updates [current_color]. *)
    if red then current_color.r <- calc_new_color current_color.r gradient_coef;
    if green then current_color.g <- calc_new_color current_color.g gradient_coef;
    if blue then current_color.b <- calc_new_color current_color.b gradient_coef;
    (* Set the new color. *)
    rgb current_color.r current_color.g current_color.b |> set_color
;;

let interpret_command command depth colored draw =
  if colored then update_color depth;
  match command with
  | Line len -> interpret_line (float_of_int len *. !scale_coef_ref) draw
  | Move len -> interpret_move (float_of_int len *. !scale_coef_ref)
  | Turn a -> interpret_turn a
  | Store -> Stack.push !current_position storage
  | Restore ->
    if Stack.is_empty storage
    then failwith "Empty stack."
    else current_position := Stack.pop storage;
    moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;
