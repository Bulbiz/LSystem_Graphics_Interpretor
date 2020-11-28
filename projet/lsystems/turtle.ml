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

let scale_coef_ref = ref 35.
let default_command = Turn 0
let initial_position = { x = 0.; y = 0.; a = 0 }
let storage = Stack.create ()
let current_position = ref initial_position
let draw_boundary = { top = 0.; right = 0.; bottom = 0.; left = 0. }
let shift = ref 1.0
let set_shifting shift_value = shift := shift_value

let get_shift () =
  let shift_value = Random.float !shift in
  Printf.printf "shift_value = %f\n" shift_value;
  shift_value
;;

(* if Random.bool () then shift_value else -shift_value *)

let reset_draw_boundary () =
  draw_boundary.top <- 0.;
  draw_boundary.right <- 0.;
  draw_boundary.bottom <- 0.;
  draw_boundary.left <- 0.
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

let interpret_command command draw =
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
