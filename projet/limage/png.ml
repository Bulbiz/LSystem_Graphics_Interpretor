open Bimage
open Graphics

(*TODO: need to unpacked [color] to get the rgb corresponding values.*)
let save_grey dest_file =
  let height = size_y () in
  let width = size_x () in
  (* Gets the corresponding 3D matrix. *)
  let img_matrix = get_image 0 0 width height |> dump_image in
  (* Creates an empty image. *)
  let img = Image.create u8 gray width height in
  (* Fills the image with the content of [img_matrix]. *)
  Image.for_each (fun x y _ -> Image.set img x y 0 img_matrix.(y).(x)) img;
  (* Save the current [img] to the [dest_file_ref]. *)
  Bimage_unix.Magick.write dest_file img
;;