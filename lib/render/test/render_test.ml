open Alcotest
open Liquid_ml

let doc_to_string = Fun.compose String.trim Cmarkit_commonmark.of_doc
let yaml = Yaml.(testable pp equal)
let error = Render.Error.(testable pp equal)

let tuple2 a b =
  Alcotest.testable
    (fun ppf (a', b') -> Fmt.pf ppf "(%a, %a)" (pp a) a' (pp b) b')
    (fun (a, b) (a', b') -> a = a' && b = b')
;;

let () =
  Alcotest.run
    "Render"
    [ ( "extract_front_matter"
      , [ ( "empty"
          , `Quick
          , fun () ->
              let text = {||} in
              let actual = Render.Markdown.extract_front_matter text in
              check'
                (result (tuple2 yaml string) error)
                ~msg:"front matter"
                ~expected:(Ok (`Null, ""))
                ~actual )
        ] )
    ; ( "convert"
      , [ ( "with context"
          , `Quick
          , fun () ->
              let text = {|hello, {{ name }}|} in
              let context = Liquid.Ctx.of_list [ "name", Liquid.String "world" ] in
              let actual = Render.render ~context text in
              check'
                (result string error)
                ~msg:"liquid"
                ~expected:(Ok "hello, world")
                ~actual )
        ; ( "yaml overrides context"
          , `Quick
          , fun () ->
              let text =
                {|
---
name: bob
---
hello, {{ name }}
                |}
              in
              let context = Liquid.Ctx.of_list [ "name", Liquid.String "world" ] in
              let actual =
                Render.Markdown.of_string ~context text |> Result.map doc_to_string
              in
              check'
                (result string error)
                ~msg:"liquid"
                ~expected:(Ok "hello, bob")
                ~actual )
        ; ( "with yaml"
          , `Quick
          , fun () ->
              let text =
                {|
---
name: world
---
hello, {{ name }}
                |}
              in
              let context = Liquid.Ctx.empty in
              let actual =
                Render.Markdown.of_string ~context text |> Result.map doc_to_string
              in
              check'
                (result string error)
                ~msg:"liquid"
                ~expected:(Ok "hello, world")
                ~actual )
        ; ( "filters"
          , `Quick
          , fun () ->
              let text =
                {|
---
name: world
---
hello, {{ name | upcase }}
                |}
              in
              let context = Liquid.Ctx.empty in
              let actual =
                Render.Markdown.of_string ~context text |> Result.map doc_to_string
              in
              check'
                (result string error)
                ~msg:"liquid"
                ~expected:(Ok "hello, WORLD")
                ~actual )
        ] )
    ]
;;
