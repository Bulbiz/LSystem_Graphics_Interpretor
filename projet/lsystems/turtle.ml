(*open Graphics*)

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

(*
let initial_position = {x = 0.; y = 0.; a = 0;}
let current_position = ref initial_position
*)
let truc = ref 0

let interpret_line i = truc := i; ();;
let interpret_move i = truc := i; ();;
let interpret_turn i = truc := i; ();;
let interpret_store = ();;
let interpret_restore = ();;

let interpret_command command = 
  match command with
  |Line i -> interpret_line i
  |Move i -> interpret_move i 
  |Turn i -> interpret_turn i
  |Store -> interpret_store
  |Restore -> interpret_restore
