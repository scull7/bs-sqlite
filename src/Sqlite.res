// Missing iterate
module Statement = {
  type t

  type columnObj = {
    name: string,
    column: string,
    table: string,
    database: string,
    type_: string,
  }

  @bs.send @variadic external run: (t, array<'a>) => Js.Json.t = "run"
  @bs.send external run_named: (t, 'a) => Js.Json.t = "run"

  @bs.send @variadic external get: (t, array<'a>) => Js.Json.t = "get"
  @bs.send external get_named: (t, 'a) => Js.Json.t = "get"
  @bs.send external get_plucked: (t) => 'b = "get"
  @bs.send external get_plucked_with_array: (t, array<'a>) => 'b = "get"

  @bs.send @variadic external all: (t, array<'a>) => Js.Array.t<Js.Json.t> = "all"
  @bs.send external all_named: (t, 'a) => Js.Json.t = "all"

  @bs.send external pluck: (t, bool) => t = "pluck"
  @bs.send external pluck_toggle: (t) => t = "pluck"

  @bs.send external expand: (t, bool) => t = "expand"
  @bs.send external expand_toggle: (t) => t = "expand"

  @bs.send external raw: (t, bool) => t = "raw"
  @bs.send external raw_toggle: (t) => t = "raw"

  @bs.send external columns: (t) => array<columnObj> = "raw"

  @bs.send @variadic external bind: (t, array<'a>) => Js.Array.t<Js.Json.t> = "bind"
  @bs.send external bind_named: (t, 'a) => Js.Json.t = "bind"

  // Properties
  @get external database: t => 'a = "database"
  @get external reader: t => bool = "reader"
  @get external source: t => string = "source"
}

// Missing aggregate, backup, pragma
module Database = {
  type t

  module Config = {
    type t
    @obj external make: (
      ~readonly: bool=?,
      ~fileMustExist: bool=?,
      ~timeout: int=?,
      ~verbose: ('a => unit)=?,
      unit
    ) => t = ""
  }

  @module @new external connect: (string, Config.t) => t = "better-sqlite3"

  let make = (~path, ~readonly=?, ~fileMustExist=?, ~timeout=?, ~verbose=?, _) =>
    connect(path, Config.make(~readonly?, ~fileMustExist?, ~timeout?, ~verbose?, ()))

  @bs.send external prepare: (t, string) => Statement.t = "prepare"

  @bs.send external transaction: (t, ('a => unit)) => ('a => unit) = "transaction"

  @bs.send external function1: (t, string, ('a) => 'b) => t = "function"
  @bs.send external function2: (t, string, ('a, 'b) => 'c) => t = "function"
  @bs.send external function3: (t, string, ('a, 'b, 'c) => 'd) => t = "function"
  @bs.send external function4: (t, string, ('a, 'b, 'c, 'd) => 'e) => t = "function"
  @bs.send external function5: (t, string, ('a, 'b, 'c, 'd, 'e) => 'f) => t = "function"
  @bs.send external function6: (t, string, ('a, 'b, 'c, 'd, 'e, 'f) => 'g) => t = "function"
  @bs.send external function7: (t, string, ('a, 'b, 'c, 'd, 'e, 'f, 'g) => 'h) => t = "function"

  @bs.send external load_extension: (t, string) => t = "loadExtension"
  @bs.send external load_extension_with_entry: (t, string, string) => t = "loadExtension"

  @bs.send external exec: (t, string) => t = "exec"

  @bs.send external close: t => t = "close"

  // Properties
  @get external in_transaction: t => bool = "inTransaction"
  @get external memory: t => bool = "memory"
  @get external name: t => string = "name"
  @get external open_: t => bool = "open"
  @get external readonly: t => bool = "readonly"
}
