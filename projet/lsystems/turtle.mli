(** Turtle graphical commands *)
type command =
  | Line of int      (** advance turtle while drawing *)
  | Move of int      (** advance without drawing *)
  | Turn of int      (** turn turtle by n degrees *)
  | Store            (** save the current position of the turtle *)
  | Restore          (** restore the last saved position not yet restored *)

(** Position and angle of the turtle *)
type position = {
  x: float;        (** position x *)
  y: float;        (** position y *)
  a: int;          (** angle of the direction *)
}

val default_command : command

(** [modify_initial_position] modify the position where the Lsystem 
    start in the graphical representation
*)
val modify_initial_position : float -> float -> int -> unit

(** [interpret_command command] simply execute the command.
    The command are :
    Move, Line, Turn, Store, Restore
*)
val interpret_command : command -> unit

