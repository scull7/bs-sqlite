
module Statement = struct
  type t

  external all : t -> 'a array -> Js.Json.t Js.Array.t = ""
  [@@bs.send] [@@bs.splice]

  external all_named : t -> 'a -> Js.Json.t = "all" [@@bs.send]

  external get : t -> 'a array -> Js.Json.t = "" [@@bs.send] [@@bs.splice]

  external get_named : t -> 'a -> Js.Json.t = "get" [@@bs.send]

  external run : t -> 'a array -> Js.Json.t = ""
  [@@bs.send] [@@bs.splice]

  external run_named : t -> 'a -> Js.Json.t = "run" [@@bs.send]

  external returns_data : t -> bool = "returnsData" [@@bs.get]

  external source : t -> string = "source" [@@bs.get]
end

module Connection = struct
  type t

  module Config = struct
    type t

    external make :
      ?memory:Js.boolean ->
      ?readonly:Js.boolean->
      ?fileMustExist:Js.boolean ->
      unit -> t = "" [@@bs.obj]
  end

  external connect : string -> Config.t -> t = "better-sqlite3"
  [@@bs.module] [@@bs.new]

  external close : t -> unit = ""
  [@@bs.send]

  let make ~path ?memory ?readonly ?fileMustExist _ =
    connect path (Config.make ?memory ?readonly ?fileMustExist ())

  external prepare : t -> string -> Statement.t = "" [@@bs.send]

  external is_open : t -> bool = "open" [@@bs.get]

  external in_transaction : t -> bool = "inTransaction" [@@bs.get]

  external name : t -> string = "name" [@@bs.get]

  external memory : t -> bool = "" [@@bs.get]

  external readonly : t -> bool = "" [@@bs.get]
end
