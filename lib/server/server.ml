type _ Effect.t += Cwd : string Effect.t

let ( / ) = Eio.Path.( / )

let handler root_dir _socket request _body writer =
  let methd = Http.Request.meth request in
  let path =
    Http.Request.resource request
    |> String.split_on_char '/'
    |> List.filter (( <> ) "")
    |> String.concat "/"
  in
  let () = Logger.info @@ fun f -> f "%a /%s" Http.Method.pp methd path in
  let path = if path = "" then "index.html" else path in
  let content_type = Magic_mime.lookup path in
  let path' = Eio.Path.(root_dir / path) in
  Eio.Path.with_open_in path'
  @@ fun flow ->
  Cohttp_eio.Server.respond
    ()
    ~status:`OK
    ~headers:(Http.Header.of_list [ "content-type", content_type ])
    ~body:flow
    writer
;;

let serve ~port ~root_dir ~env ~sw =
  let socket =
    Eio.Net.listen
      env#net
      ~sw
      ~backlog:128
      ~reuse_addr:true
      (`Tcp (Eio.Net.Ipaddr.V4.loopback, port))
  and server = Cohttp_eio.Server.make ~callback:(handler root_dir) () in
  Cohttp_eio.Server.run socket server ~on_error:Logger.exn
;;
