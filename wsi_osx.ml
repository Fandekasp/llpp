external stub_reshape: int -> int -> unit = "stub_reshape"
external stub_set_title: string -> unit = "stub_set_title"

let debug = true

type cursor =
    | CURSOR_INHERIT
    | CURSOR_INFO
    | CURSOR_CYCLE
    | CURSOR_FLEUR
    | CURSOR_TEXT

type winstate =
    | MaxVert
    | MaxHorz
    | Fullscreen

type visiblestate =
  | Unobscured
  | PartiallyObscured
  | FullyObscured

class type t = object
  method display  : unit
  method map      : bool -> unit
  method expose   : unit
  method visible  : visiblestate -> unit
  method reshape  : int -> int -> unit
  method mouse    : int -> bool -> int -> int -> int -> unit
  method motion   : int -> int -> unit
  method pmotion  : int -> int -> unit
  method key      : int -> int -> unit
  method enter    : int -> int -> unit
  method leave    : unit
  method winstate : winstate list -> unit
  method quit     : unit
end

let onot = object
  method display         = ()
  method map _           = ()
  method expose          = ()
  method visible _       = ()
  method reshape _ _     = ()
  method mouse _ _ _ _ _ = ()
  method motion _ _      = ()
  method pmotion _ _     = ()
  method key _ _         = ()
  method enter _ _       = ()
  method leave           = ()
  method winstate _      = ()
  method quit            = exit 0
end

let t : t ref = ref onot

let setcursor _ = ()

let settitle s =
  stub_set_title s

let swapb () = ()

let reshape w h =
  stub_reshape w h

let key_down key mask =
  if debug then Printf.eprintf "key down: %d %x\n%!" key mask;
  !t#key key mask

let key_up key mask =
  if debug then Printf.eprintf "key up: %d %x\n%!" key mask;
  !t#key key mask

let mouse_down b x y mask =
  if debug then Printf.eprintf "mouse down: %d %d %x\n%!" x y mask;
  !t#mouse b true x y mask

let mouse_up b x y mask =
  if debug then Printf.eprintf "mouse up: %d %d %x\n%!" x y mask;
  !t#mouse b false x y mask

let mouse_moved x y =
  if debug then Printf.eprintf "mouse moved: %d %d\n%!" x y;
  !t#motion x y

let quit () =
  if debug then Printf.eprintf "quit\n%!";
  !t#quit

let () =
  Callback.register "llpp_key_down" key_down;
  Callback.register "llpp_key_up" key_up;
  Callback.register "llpp_mouse_down" mouse_down;
  Callback.register "llpp_mouse_up" mouse_up;
  Callback.register "llpp_mouse_moved" mouse_moved;
  Callback.register "llpp_quit" quit

let readresp _ = ()

let init t _ w h platform = Unix.stdin, 0, 0

let fullscreen () = ()

let activatewin () = ()

let mapwin () = ()

let metamask = 1 lsl 19

let altmask = 1 lsl 19

let shiftmask = 1 lsl 17

let ctrlmask = 1 lsl 18

let withalt mask = mask land metamask != 0

let withctrl mask = mask land ctrlmask != 0

let withshift mask = mask land shiftmask != 0

let withmeta mask = mask land metamask != 0

let withnone mask = mask land (altmask + ctrlmask + shiftmask + metamask) = 0

let keyname _ = ""

let namekey _ = 0

let setwinbgcol _ = ()
