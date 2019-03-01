open Printf
open Scanf

(* let brightness_file = "/sys/class/backlight/intel_backlight/brightness"
 * let max_brightness_file = "/sys/class/backlight/intel_backlight/max_brightness" *)

let brightness_file = "BRIGHTNESS"
let max_brightness_file = "MAX_BRIGHTNESS"

let current_brightness =
  let ic = open_in brightness_file in
  let line = input_line ic in
  let value = sscanf line "%d" (fun a -> a) in
  close_in ic; value

let max_brightness =
  let ic = open_in max_brightness_file in
  let line = input_line ic in
  let value = sscanf line "%d" (fun a -> a) in
  close_in ic; value

let min_brightness = (max_brightness / 200)

let exec, op, value =
  let f =
    let args = Array.to_list Sys.argv in
    match args with
    | exec :: op :: value :: [] -> exec, op, value
    | exec :: op :: [] -> exec, op, " "
    | _ -> Sys.argv.(0), " ", " "
  in
  f

let help = sprintf "Usage %s : +/-/= <value>\n" exec

type opt =
  | Plus of int
  | Equal of int
  | Minus of int
  | Max
  | Min
  | Print

let rval v =
  (v * max_brightness ) / 100

let pval v =
  (v * 100) / max_brightness

let new_brightness =
  let op =
    let get_op =
      match op with
      | "+" -> Plus (int_of_string value)
      | "-" -> Minus (int_of_string value)
      | "=" -> if value = "max" then Max
               else if value = "min" then Min
               else Equal (int_of_string value)
      | " " -> Print
      | _   -> printf "%s" help; Print
    in get_op

  in match op with
     | Plus v -> if current_brightness + (rval v) > max_brightness then
                   max_brightness else current_brightness + (rval v)
     | Minus v -> if current_brightness - (rval v) < min_brightness then
                    min_brightness else current_brightness - (rval v)
     | Equal v -> if (rval v) < min_brightness then min_brightness
                  else if (rval v) > max_brightness then max_brightness
                  else (rval v)
     | Print -> printf "Brightness = %d\n" (pval current_brightness);
                current_brightness
     | Max -> max_brightness
     | Min -> min_brightness

let () =
  let write =
    let oc = open_out brightness_file in
    fprintf oc "%d" new_brightness;
    close_out oc
  in write
