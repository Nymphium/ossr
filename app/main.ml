let name = "it-is-test.server"

let () = Logs.set_reporter (Logs_fmt.reporter ())
and () = Logs.Src.set_level Cohttp_eio.src (Some Debug)

let parse_log_level =
  let open Logs in
  function
  | "debug" -> Some Debug
  | "info" -> Some Info
  | "warning" -> Some Warning
  | "error" -> Some Error
  | "app" -> Some App
  | _ -> None
;;

let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let log_level' = ref "info" in
  let port' = ref 8080 in
  let dir' = ref "" in
  let () =
    Arg.parse
      [ "-p", Arg.Set_int port', "Listening port number (8080 by default)"
      ; ( "-D"
        , Arg.Set_string dir'
        , "Change contents root path (current directory by default)" )
      ; "-l", Arg.Set_string log_level', "Log level (info by default)"
      ]
      ignore
      name
  in
  let () =
    let log_level =
      match parse_log_level !log_level' with
      | Some l -> l
      | _ -> invalid_arg "log_level"
    in
    Logs.Src.set_level Cohttp_eio.src @@ Some log_level
  in
  let root_dir =
    if !dir' = ""
    then Eio.Stdenv.cwd env
    else (
      let ( / ) = Eio.Path.( / ) in
      let dir = !dir' in
      if String.starts_with ~prefix:"/" dir
      then Eio.Stdenv.fs env / dir
      else Eio.Stdenv.cwd env / dir)
  in
  Server.serve ~root_dir ~port:!port' ~env ~sw
;;
