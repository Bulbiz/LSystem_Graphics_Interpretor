open Graphics

type command =
  | Line of int
  | Move of int
  | Turn of int
  | Store
  | Restore

type position = {
  x : float;  (** position x *)
  y : float;  (** position y *)
  a : int;  (** angle of the direction *)
}

let default_command = Turn 0


let initial_position = {x = 0.; y = 0.; a = 0;}
let current_position = ref initial_position
let storage = Stack.create ()


let update_current_position i a =
  let angle = float_of_int (!current_position).a in
  let longueur = float_of_int i in

  let new_x = (!current_position).x +. cos(angle) *. longueur in 
  let new_y = (!current_position).x +. sin(angle) *. longueur in 
  let new_a = (!current_position).a + a in 
  
  current_position := {
    x = new_x;
    y = new_y;
    a = new_a;
  }
;;

let interpret_line i = 
  update_current_position i 0 ;
  lineto (int_of_float (!current_position).x) (int_of_float (!current_position).y)
;;

let interpret_move i =
  update_current_position i 0;
  moveto (int_of_float (!current_position).x) (int_of_float (!current_position).y)
;;

let interpret_turn a = 
  update_current_position 0 a
;;

let interpret_store = 
  Stack.push (!current_position) storage
;;

let interpret_restore = 
  if Stack.is_empty storage then 
    failwith "Impossible de charger la position"
  else
    current_position := Stack.pop storage
;;

let interpret_command command = 
  match command with
  |Line i -> interpret_line i
  |Move i -> interpret_move i 
  |Turn a -> interpret_turn a
  |Store -> interpret_store
  |Restore -> interpret_restore
;;
