open Graphics

(** Turtle graphical commands *)
type command =
  | Line of int (** advance turtle while drawing *)
  | Move of int (** advance without drawing *)
  | Turn of int (** turn turtle by n degrees *)
  | Store (** save the current position of the turtle *)
  | Restore (** restore the last saved position not yet restored *)

(** Position and angle of the turtle *)
type position =
  { x : float (** position x *)
  ; y : float (** position y *)
  ; a : int (** angle of the direction *)
  }

(** Maximums positions reached by the turtle. *)
type draw_boundary =
  { mutable top : float
  ; mutable right : float
  ; mutable bottom : float
  ; mutable left : float
  }

(** Color in RGB. *)
type color_rgb =
  { mutable r : int
  ; mutable g : int
  ; mutable b : int
  }

(** Boolean tuple for keep tracking of the current color chanel wanted to be updated. *)
type color_value = Color of bool * bool * bool

(** Globals references. *)

(* This are references because they need to be initialized by the main. *)
let scale_coef_ref = ref 35.
let shift = ref 1.0
let set_shifting shift_value = shift := shift_value
let color_ref = ref (Color (true, true, true))
let initial_position = { x = 0.; y = 0.; a = 0 }
let current_position = ref initial_position
let positions_stack = Stack.create ()
let draw_boundary = { top = 0.; right = 0.; bottom = 0.; left = 0. }
let current_color = { r = 10; g = 10; b = 10 }
let default_command = Turn 0

(** [get_shift] returns a random float value according the [shift] value. *)
let get_shift () =
  let shift_value = Random.float !shift in
  if Random.bool () then -1. *. shift_value else shift_value
;;

(** Reset [draw_boundary] to its initial value. *)
let reset_draw_boundary () =
  draw_boundary.top <- 0.;
  draw_boundary.right <- 0.;
  draw_boundary.bottom <- 0.;
  draw_boundary.left <- 0.
;;

(** [reset_color] set the current color to its default value. *)
let reset_color () =
  current_color.r <- 10;
  current_color.g <- 10;
  current_color.b <- 10
;;

(** [modify_initial_position initial_x initial_y initiale_a]
    modifies the starting position of the turtle in the graph.
*)
let modify_initial_position initial_x initial_y initial_a =
  current_position := { x = initial_x; y = initial_y; a = initial_a };
  moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

(** Returns the corresponding [angle] value in radian. *)
let convert_degree_to_radian angle = angle *. (Float.pi /. 180.)

(** Updates the [current_position] according a length and an angle. *)
let update_current_position len a =
  let angle =
    convert_degree_to_radian (float_of_int !current_position.a +. get_shift ())
  in
  let new_x = !current_position.x +. (cos angle *. len) in
  let new_y = !current_position.y +. (sin angle *. len) in
  let new_a = !current_position.a + a in
  current_position := { x = new_x; y = new_y; a = new_a }
;;

(** Updates the [draw_boundary] according to the current turtle position if needed. *)
let update_draw_limits curr_x curr_y =
  if curr_y > draw_boundary.top || 0. = draw_boundary.top then draw_boundary.top <- curr_y;
  if curr_x > draw_boundary.right || 0. = draw_boundary.right
  then draw_boundary.right <- curr_x;
  if curr_y < draw_boundary.bottom || 0. = draw_boundary.bottom
  then draw_boundary.bottom <- curr_y;
  if curr_x < draw_boundary.left || 0. = draw_boundary.left
  then draw_boundary.left <- curr_x
;;

(** Updates the [current_position] and the [draw_boundary] according a length and an angle. *)
let update_state len a =
  update_current_position len a;
  update_draw_limits !current_position.x !current_position.y
;;

(** Interprets a [Line] command. *)
let interpret_line len draw =
  update_state len 0;
  if draw
  then lineto (int_of_float !current_position.x) (int_of_float !current_position.y)
  else moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

(** Interprets a [Move] command. *)
let interpret_move len =
  update_state len 0;
  moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;

(** Interprets a [Turn] command. *)
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

(** [interpret_command command depth draw] interprets a command with the
    corresponding turtle action in the graph.
    *)
let interpret_command command depth colored draw =
  if colored then update_color depth;
  match command with
  | Line len -> interpret_line (float_of_int len *. !scale_coef_ref) draw
  | Move len -> interpret_move (float_of_int len *. !scale_coef_ref)
  | Turn a -> interpret_turn a
  | Store -> Stack.push !current_position positions_stack
  | Restore ->
    if Stack.is_empty positions_stack
    then failwith "Empty stack."
    else current_position := Stack.pop positions_stack;
    moveto (int_of_float !current_position.x) (int_of_float !current_position.y)
;;
