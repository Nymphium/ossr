open Liquid_ml

let[@tmc] rec of_yaml : Yaml.value -> Liquid.value =
  let open Liquid in
  function
  | `String value -> String value
  | `A values -> List (List.map of_yaml values)
  | `Bool value -> Bool value
  | `Float value -> Number value
  | `Null -> Nil
  | `O values -> Object (Object.of_list @@ List.map (fun (k, v) -> k, of_yaml v) values)
;;

let apply ~context content =
  let open Liquid in
  let settings =
    Settings.make ~log_policy:Settings.Verbose ~error_policy:Settings.Strict ~context ()
  in
  try render_text ~settings content |> Result.ok with
  | exn -> Result.error @@ Error.Exn exn
;;

module Context = struct
  let of_yaml : Yaml.value -> Liquid_syntax.Syntax.value Liquid.Ctx.t =
    let rec aux acc v =
      match v with
      | [] -> acc
      | (key, value) :: rest -> aux ((key, of_yaml value) :: acc) rest
    in
    function
    | `O metadata -> Liquid.Ctx.of_list @@ aux [] metadata
    | _ -> Liquid.Ctx.empty
  ;;

  let merge_naive =
    let merge _ lhs rhs =
      match lhs, rhs with
      | Some lhs, None -> Some lhs
      | _, Some rhs -> Some rhs
      | _ -> None
    in
    fun l r -> Liquid_ml.Liquid.Ctx.merge merge l r
  ;;
end
