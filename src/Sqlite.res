module Statement = {
  type t

  @bs.send @variadic external all: (t, array<'a>) => Js.Array.t<Js.Json.t> = "all"
  @bs.send external all_named: (t, 'a) => Js.Json.t = "all"
  @bs.send @variadic external get: (t, array<'a>) => Js.Json.t = "get"
  @bs.send external get_named: (t, 'a) => Js.Json.t = "get"
  @bs.send @variadic external run: (t, array<'a>) => Js.Json.t = "run"
  @bs.send external run_named: (t, 'a) => Js.Json.t = "run"
  @get external returns_data: t => bool = "returnsData"
  @get external source: t => string = "source"
}

module Connection = {
  type t

  module Config = {
    type t
    @obj external make: (~readonly: bool=?, ~fileMustExist: bool=?, unit) => t = ""
  }

  @module @new external connect: (string, Config.t) => t = "better-sqlite3"
  @bs.send external close: t => unit = "close"

  let make = (~path, ~readonly=?, ~fileMustExist=?, _) =>
    connect(path, Config.make(~readonly?, ~fileMustExist?, ()))

  @bs.send external prepare: (t, string) => Statement.t = "prepare"
  @get external is_open: t => bool = "open"
  @get external in_transaction: t => bool = "inTransaction"
  @get external name: t => string = "name"
  @get external readonly: t => bool = "readonly"
}
