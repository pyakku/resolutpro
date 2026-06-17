addon subsidiary_table_of_companies {
  input {
    int subsidiary? {
      table = "companies"
    }
  }

  stack {
    db.query subsidiary_table {
      where = $db.subsidiary_table.subsidiary == $input.subsidiary
      return = {type: "single"}
    }
  }
}