open struct
  let pp_exn = Fmt.of_to_string Printexc.to_string
  let equal_exn = ( = )
end

type t =
  | String of string
  | Exn of exn
[@@deriving show, eq]
