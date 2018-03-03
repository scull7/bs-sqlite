open Jest

type simple_result = {
  result: int
}

type insert_result = {
  changes: int;
  last_insert_id: int;
}

type test_all_row = {
  id: int option;
  foo: string;
}

type test_file_row = {
  bar: string;
  baz: string;
}

let decode_insert_result json = Json.Decode.({
  changes = json |> field "changes" int;
  last_insert_id = json |> field "lastInsertROWID" int;
})

let decode_test_all_row json = Json.Decode.({
  id = json |> field "id" (optional int);
  foo = json |> field "foo" string;
})

let decode_test_file_row json = Json.Decode.({
  bar = json |> field "bar" string;
  baz = json |> field "baz" string;
})

let runner db expected sql fn = (fun () ->
  Sqlite.Connection.prepare db sql
  |> fn
  |> Json.Decode.field "result" Json.Decode.int
  |> Expect.expect
  |> Expect.toBe expected
)

let () =

describe "Basic functionality" (fun () ->
  let db = Sqlite.Connection.make ~path:"test.db" ~memory:Js.true_ ()
  in
  test "Should be able to execute a simple select" (runner db 2
    "SELECT 1+1 AS result"
    (fun s -> Sqlite.Statement.get s [||])
  );

  test "Should interpolate un-named parameters" (runner db 3
    "SELECT ? + ? AS result"
    (fun s -> Sqlite.Statement.get s [|1; 2|])
  );

  test "Should interpolate :named parameters" (runner db 3
    "SELECT :x + :y AS result"
    (fun s -> Sqlite.Statement.get_named s [%bs.obj{ x=1; y=2 }])
  );

  test "Should interpolate $named parameters" (runner db 12
    "SELECT $x + $y AS result"
    (fun s -> Sqlite.Statement.get_named s [%bs.obj{ x=5; y=7 }])
  );

  test "Should interpolate @named parameters" (runner db 18
    "SELECT @x + @y AS result"
    (fun s -> Sqlite.Statement.get_named s [%bs.obj{ x=3; y=15 }])
  );
);

describe "`all` and `run` functions" (fun () ->
  let db = Sqlite.Connection.make ~path:"test.db" ~memory:Js.true_ ()
  in
  beforeAllAsync (fun finish ->
    let _ = Sqlite.Connection.prepare db {|
      CREATE TABLE `test_all_and_run` (
        `id` INTEGER PRIMAY KEY
      , `foo`
      )
    |}
    |> (fun s -> Sqlite.Statement.run s [||])
    in
    finish ()
  );

  afterAllAsync (fun finish ->
    let _ = Sqlite.Connection.prepare db {| DROP TABLE `test_all_and_run` |}
            |> (fun s -> Sqlite.Statement.run s [||])
    in
    finish ()
  );

  test "INSERT a record" (fun () ->
    Sqlite.Connection.prepare db {|
      INSERT INTO `test_all_and_run` (`foo`) VALUES ('moo')
    |}
    |> (fun s -> Sqlite.Statement.run s [||])
    |> decode_insert_result
    |> (fun { changes; last_insert_id; } -> [| changes; last_insert_id; |])
    |> Expect.expect
    |> Expect.toBeSupersetOf [| 1; 1 |]
  );

  test "Retrieve the newly inserted record" (fun () ->
    Sqlite.Connection.prepare db {|
      SELECT * FROM `test_all_and_run` WHERE `foo` = 'moo'
    |}
    |> (fun s -> Sqlite.Statement.all s [||])
    |> (fun a -> Belt_Array.map a decode_test_all_row)
    |> (fun a -> Belt_Array.get a 0)
    |> (fun a -> Js.Option.map (fun [@bs] { foo; _; } -> [| foo |]) a)
    |> Js.Option.getWithDefault [||]
    |> Expect.expect
    |> Expect.toBeSupersetOf [| "moo"; |]
  );
);

describe "File based database" (fun () ->
  let db_path = "/tmp/test.db"
  in
  beforeAll (fun () ->
    let db = Sqlite.Connection.make ~path:db_path ()
    in
    let _ = Sqlite.Connection.prepare db {|
      CREATE TABLE `test_file_db` (
        `bar`
      , `baz`
      )
    |}
    |> (fun s -> Sqlite.Statement.run s [||])
    in
    ()
  );
  afterAll(fun () -> Node.Fs.unlinkSync db_path);

  test "insert and retrieve record from file database" (fun () ->
    let db = Sqlite.Connection.make ~path:db_path ~fileMustExist:Js.true_ ()
    in
    Sqlite.Connection.prepare db {|
      INSERT INTO `test_file_db` (`bar`, `baz`) VALUES ('moo', 'cow')
    |}
    |> (fun s -> Sqlite.Statement.run s [||])
    |> decode_insert_result
    |> (fun { changes; last_insert_id; } -> [| changes; last_insert_id; |])
    |> Expect.expect
    |> Expect.toBeSupersetOf [| 1; 1 |]
  );

  ()
);
