let extract_front_matter content : (Yaml.value * string, Error.t) result =
  let[@tmc] rec aux acc = function
    | [] -> acc, []
    | "---" :: rest -> push_lines acc rest
    | line :: rest ->
      let acc', rest' = aux acc rest in
      acc', line :: rest'
  and push_lines acc = function
    | [] -> List.rev acc, []
    | "---" :: rest -> List.rev acc, rest
    | line :: rest -> push_lines (line :: acc) rest
  in
  let lines = String.split_on_char '\n' content in
  let metadata, content = aux [] lines in
  match String.concat "\n" metadata |> Yaml.of_string with
  | Ok ((`O _ | `Null) as metadata) ->
    Result.ok (metadata, String.(trim @@ concat "\n" content))
  | Ok _ ->
    Result.error @@ Error.String "Invalid front matter: topl evel must be an object"
  | Error (`Msg err) -> Result.error @@ Error.String err
;;

let context_from_metadata metadata =
  let open Liquid_ml.Liquid in
  let rec aux acc (v : (string * Yaml.value) list) =
    match v with
    | [] -> acc
    | (key, value) :: rest -> aux ((key, Liquid.of_yaml value) :: acc) rest
  in
  Ctx.of_list @@ aux [] metadata
;;

let of_string ~context content =
  let open Let.Result in
  let@ metadata, content = extract_front_matter content in
  let context =
    let ctx = Liquid.Context.of_yaml metadata in
    Liquid.Context.merge_naive context ctx
  in
  Result.map Cmarkit.Doc.of_string (Liquid.apply ~context content)
;;
