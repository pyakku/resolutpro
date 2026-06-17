query get_subsidiaries verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int companies_id? {
      table = "companies"
    }
  }

  stack {
    db.query subsidiary_table {
      where = $input.companies_id == $db.subsidiary_table.parent_company
      return = {type: "list", distinct: "no"}
      output = ["subsidiary", "approved", "rejected"]
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.subsidiary}
          as   : "_companies"
        }
      ]
    } as $subsidiary_table_1
  }

  response = $subsidiary_table_1
}