module Error = Error
module Liquid = Liquid
module Markdown = Markdown

let render ~context =
  Fun.compose
    (Result.map @@ Fun.compose String.trim Cmarkit_commonmark.of_doc)
    (Markdown.of_string ~context)
;;
