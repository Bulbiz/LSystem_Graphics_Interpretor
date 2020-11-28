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

val default_command : command

(** Stores maximums positions reached by the turtle. *)
val draw_boundary : draw_boundary

(** Reset [draw_boundary] to its initial value. *)
val reset_draw_boundary : unit -> unit

(** Is the scalling ratio. *)
val scale_coef_ref : float ref

(** [modify_initial_position initial_x initial_y initiale_a]
    modifies the position where the Lsystem starts in the graph.
*)
val modify_initial_position : float -> float -> int -> unit

(** [interpret_command command draw] interprets a command with the corresponding turtle
    action in the graph.
*)
val interpret_command : command -> bool -> unit

(** [set_shifting shift_value] set the max value for the aleatory shifting for the interpretation *)
val set_shifting : float -> unit
