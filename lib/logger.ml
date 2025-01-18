open struct
  let src = Cohttp_eio.src
end

let debug fmtr = Logs.debug ~src fmtr
let info fmtr = Logs.info ~src fmtr
let warn fmtr = Logs.warn ~src fmtr
let error fmtr = Logs.err ~src fmtr
let exn exn = Logs.err ~src (fun f -> f "%a" Eio.Exn.pp exn)
