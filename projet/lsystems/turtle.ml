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

type color_enum = Red | Blue | Green | Gray

let scale_coef_ref = ref 35.
let default_command = Turn 0
let initial_position = { x = 0.; y = 0.; a = 0 }
let storage = Stack.create ()
let current_position = ref initial_position
let draw_boundary = { top = 0.; right = 0.; bottom = 0.; left = 0. }
let shift = ref 1.0
let set_shifting shift_value = shift := shift_value
let current_color = { r = 10; g = 10; b = 10 }
let color_ref = ref Gray 

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

let set_color_interpretation color =
  match color with
  |"red" -> color_ref := Red
  |"blue" -> color_ref := Blue
  |"green" -> color_ref := Green
  |_ -> color_ref := Gray
;;
(*
let set_red_gradiant depth = 
  current_color.r <- current_color.r * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  set_color (rgb (255 - current_color.r) current_color.g current_color.b)
;;

let set_green_gradiant depth = 
  current_color.g <- current_color.g * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  set_color (rgb current_color.r (255 - current_color.g) current_color.b)
;;

let set_blue_gradiant depth = 
  current_color.b <- current_color.b * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  set_color (rgb current_color.r current_color.g (255 - current_color.b))
;;

let set_gray_gradiant depth = 
  current_color.r <- current_color.r * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  current_color.g <- current_color.g * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  current_color.b <- current_color.b * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  set_color (rgb (255 - current_color.r) (255 - current_color.g) (255 - current_color.b))
;;
*)
let set_color_gradiant depth (red:bool) (green:bool) (blue:bool) = 
  if (red) then current_color.r <- current_color.r * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  if (green) then current_color.g <- current_color.g * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;
  if (blue) then current_color.b <- current_color.b * (depth / (int_of_float !scale_coef_ref + 50)) mod 255;

  let red_set_color = if (red) then 255 - current_color.r else current_color.r in
  let green_set_color = if (green) then 255 - current_color.g else current_color.g in
  let blue_set_color = if (blue) then 255 - current_color.b else current_color.b in

  set_color (rgb red_set_color green_set_color blue_set_color)
;;

let set_gradiant depth =
  match !color_ref with
  |Red -> set_color_gradiant depth true false false(*set_red_gradiant depth*)
  |Green -> set_color_gradiant depth false true false(*set_green_gradiant depth*)
  |Blue -> set_color_gradiant depth false false true(*set_blue_gradiant depth*)
  |Gray -> set_color_gradiant depth true true true(*set_gray_gradiant depth*)
;;

let interpret_command command depth colored draw =
  if colored
  then (set_gradiant depth);
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
