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
