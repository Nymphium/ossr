module type M = sig
  type 'a t

  val return : 'a -> 'a t
  val ( let@ ) : 'a t -> ('a -> 'b t) -> 'b t
end

module Result = struct
  type 'a t = ('a, string) result

  let ( let@ ) x f =
    match x with
    | Ok x -> f x
    | Error _ as e -> e
  ;;

  let return = Result.ok
end

module Option = struct
  type 'a t = 'a option

  let ( let@ ) x f =
    match x with
    | Some x -> f x
    | None -> None
  ;;

  let return = Option.some
end
