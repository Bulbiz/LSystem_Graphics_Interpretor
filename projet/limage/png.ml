open Bimage
open Graphics

(* Calcul in order to unpack rgb values found here:
      https://caml.inria.fr/pub/docs/oreilly-book/html/book-ora048.html
    *)
let set_rgb img x y (c : Graphics.color) =
  let r = c / 65536
  and g = c / 256 mod 256
  and b = c mod 256 in
  Image.set img x y 0 r;
  Image.set img x y 1 g;
  Image.set img x y 2 b
;;

let save_to dest_file =
  let height = size_y () in
  let width = size_x () in
  (* Gets the corresponding 3D matrix. *)
  let img_matrix = get_image 0 0 width height |> dump_image in
  (* Creates an empty image. *)
  let img = Image.create u8 Bimage.rgb width height in
  (* Fills the image with the content of [img_matrix]. *)
  Image.for_each (fun x y _ -> set_rgb img x y img_matrix.(y).(x)) img;
  (* Save the current [img] to the [dest_file_ref]. *)
  Bimage_unix.Magick.write dest_file img
;;
