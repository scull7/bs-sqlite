open Jest

type simple_result = {result: int}

type insert_result = {
  changes: int,
  last_insert_id: int,
}

type test_all_row = {
  id: option<int>,
  foo: string,
}

type test_file_row = {
  bar: string,
  baz: string,
}

let decode_insert_result = json => {
  open Json.Decode
  {
    changes: json |> field("changes", int),
    last_insert_id: json |> field("lastInsertRowid", int),
  }
}

let decode_test_all_row = json => {
  open Json.Decode
  {
    id: json |> field("id", optional(int)),
    foo: json |> field("foo", string),
  }
}

let decode_test_file_row = json => {
  open Json.Decode
  {
    bar: json |> field("bar", string),
    baz: json |> field("baz", string),
  }
}

let runner = (db, expected, sql, fn, ()) =>
  Sqlite.Connection.prepare(db, sql)
  |> fn
  |> Json.Decode.field("result", Json.Decode.int)
  |> Expect.expect
  |> Expect.toBe(expected)

let () = {
  describe("Basic functionality", () => {
    let db = Sqlite.Connection.make(~path=":memory:", ())

    test(
      "Should be able to execute a simple select",
      runner(db, 2, "SELECT 1+1 AS result", s => Sqlite.Statement.get(s, [])),
    )

    test(
      "Should interpolate un-named parameters",
      runner(db, 3, "SELECT ? + ? AS result", s => Sqlite.Statement.get(s, [1, 2])),
    )

    test(
      "Should interpolate :named parameters",
      runner(db, 3, "SELECT :x + :y AS result", s =>
        Sqlite.Statement.get_named(s, {"x": 1, "y": 2})
      ),
    )

    test(
      "Should interpolate $named parameters",
      runner(db, 12, "SELECT $x + $y AS result", s =>
        Sqlite.Statement.get_named(s, {"x": 5, "y": 7})
      ),
    )

    test(
      "Should interpolate @named parameters",
      runner(db, 18, "SELECT @x + @y AS result", s =>
        Sqlite.Statement.get_named(s, {"x": 3, "y": 15})
      ),
    )
  })

  describe("`all` and `run` functions", () => {
    let db = Sqlite.Connection.make(~path=":memory:", ())

    beforeAllAsync(finish => {
      let _ = Sqlite.Connection.prepare(
        db,
        `
      CREATE TABLE \`test_all_and_run\` (
        \`id\` INTEGER PRIMAY KEY
      , \`foo\`
      )
    `,
      ) |> (s => Sqlite.Statement.run(s, []))

      finish()
    })

    afterAllAsync(finish => {
      let _ =
        Sqlite.Connection.prepare(db, ` DROP TABLE \`test_all_and_run\` `) |> (
          s => Sqlite.Statement.run(s, [])
        )

      finish()
    })

    test("INSERT a record", () =>
      Sqlite.Connection.prepare(
        db,
        `
      INSERT INTO \`test_all_and_run\` (\`foo\`) VALUES ('moo')
    `,
      )
      |> (s => Sqlite.Statement.run(s, []))
      |> decode_insert_result
      |> (({changes, last_insert_id}) => [changes, last_insert_id])
      |> Expect.expect
      |> Expect.toBeSupersetOf([1, 1])
    )

    test("Retrieve the newly inserted record", () =>
      Sqlite.Connection.prepare(
        db,
        `
      SELECT * FROM \`test_all_and_run\` WHERE \`foo\` = 'moo'
    `,
      )
      |> (s => Sqlite.Statement.all(s, []))
      |> (a => Belt_Array.map(a, decode_test_all_row))
      |> (a => Belt_Array.get(a, 0))
      |> (a => Js.Option.map((. {foo, _}) => [foo], a))
      |> Js.Option.getWithDefault([])
      |> Expect.expect
      |> Expect.toBeSupersetOf(["moo"])
    )
  })

  describe("File based database", () => {
    let db_path = "/tmp/test.db"

    beforeAll(() => {
      let db = Sqlite.Connection.make(~path=db_path, ())

      let _ = Sqlite.Connection.prepare(
        db,
        `
      CREATE TABLE \`test_file_db\` (
        \`bar\`
      , \`baz\`
      )
    `,
      ) |> (s => Sqlite.Statement.run(s, []))
    })
    afterAll(() => Node.Fs.unlinkSync(db_path))

    test("insert and retrieve record from file database", () => {
      let db = Sqlite.Connection.make(~path=db_path, ~fileMustExist=true, ())

      Sqlite.Connection.prepare(
        db,
        `
      INSERT INTO \`test_file_db\` (\`bar\`, \`baz\`) VALUES ('moo', 'cow')
    `,
      )
      |> (s => Sqlite.Statement.run(s, []))
      |> decode_insert_result
      |> (({changes, last_insert_id}) => [changes, last_insert_id])
      |> Expect.expect
      |> Expect.toBeSupersetOf([1, 1])
    })

    test("read-only flag", () => {
      let db = Sqlite.Connection.make(~path=db_path, ~readonly=true, ())

      Expect.expect(() =>
        Sqlite.Connection.prepare(
          db,
          `
        INSERT INTO \`test_file_db\` (\`bar\`, \`baz\`) VALUES ('fail', 'stuff')
      `,
        ) |> (s => Sqlite.Statement.run(s, []))
      ) |> Expect.toThrow
    })

    ()
  })
}
