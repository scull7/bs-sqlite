# bs-sqlite
Bindings to the [better-sqlite3] module for interaction with Sqlite databases.

## Usage

### Basic Select
```ocaml
  let db = Sqlite.Connection.make ~path:"test.db" ~memory:Js.true_ ()

  let _ = Sqlite.Connection.prepare db "SELECT 1 + 1 AS result"
        |> Sqlite.Statement.get [||]
        |> Js.log
  )
```

### Use un-named parameters
```ocaml
  let db = Sqlite.Connection.make ~path:"test.db" ~memory:Js.true_ ()

  let _ = Sqlite.Connection.prepare db "SELECT ? + ? AS result"
        |> Sqlite.Statement.get [|1; 1|]
        |> Js.log
  )
```

## How do I install it?

Inside of a BuckleScript project:

```shell
yarn install --save bs-sqlite
```

Then add `bs-sqlite` to your `bs-dependencies` in `bsconfig.json`:

```json
{
  "bs-dependencies": [ "bs-sqlite" ]
}
```

[better-sqlite3]: https://github.com/JoshuaWise/better-sqlite3
