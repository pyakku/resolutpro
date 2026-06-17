// Query all subsidiary_table records
query subsidiary_table verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query subsidiary_table {
      return = {type: "list"}
    } as $subsidiary_table
  }

  response = $subsidiary_table
}