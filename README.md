[![Build Status](https://www.travis-ci.org/scull7/bs-sqlite.svg?branch=master)](https://www.travis-ci.org/scull7/bs-sqlite)
[![Coverage Status](https://coveralls.io/repos/github/scull7/bs-sqlite/badge.svg?branch=master)](https://coveralls.io/github/scull7/bs-sqlite?branch=master)
[![NPM version](http://img.shields.io/npm/v/bs-sqlite.svg)](https://www.npmjs.org/package/bs-sqlite)

# bs-sqlite
Bindings to the [better-sqlite3] module for interaction with Sqlite databases.

## Usage

### Basic Select
```rescript
let db = Sqlite.Database.make(~path=":memory:", ())
let _ =
  Sqlite.Database.prepare(db, "SELECT 1 + 1 AS result") -> Sqlite.Statement.get([]) -> Js.log
```

### Use un-named parameters
```rescript
let db = Sqlite.Database.make(~path=":memory:", ())
let _ =
  Sqlite.Database.prepare(db, "SELECT 1 + 1 AS result") -> Sqlite.Statement.get([]) -> Js.log
```

### Use named parameters

#### Using :x format
```rescript
let db = Sqlite.Database.make(~path=":memory:", ())

let _ =
  Sqlite.Database.prepare(db, "SELECT :x + :y AS result")
  -> Sqlite.Statement.get_named({"x": 1, "y": 2})
  -> Js.log
```

#### Using $x format
```rescript
let db = Sqlite.Database.make(~path=":memory:", ())

let _ =
  Sqlite.Database.prepare(db, "SELECT $x + $y AS result")
  -> Sqlite.Statement.get_named({"x": 1, "y": 2})
  -> Js.log
```

#### Using @x format
```rescript
let db = Sqlite.Database.make(~path=":memory:", ())

let _ =
  Sqlite.Database.prepare(db, "SELECT @x + @y AS result")
  -> Sqlite.Statement.get_named({"x": 1, "y": 2})
  -> Js.log
```

## How do I install it?

Inside of a BuckleScript project:

```shell
npm install --save bs-sqlite
```

Then add `bs-sqlite` to your `bs-dependencies` in `bsconfig.json`:

```json
{
  "bs-dependencies": [ "bs-sqlite" ]
}
```

[better-sqlite3]: https://github.com/JoshuaWise/better-sqlite3
