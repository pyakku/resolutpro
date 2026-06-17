query current_company_parent verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query subsidiary_table {
      where = $db.subsidiary_table.subsidiary == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name : "parent_company"
          input: {companies_id: $output.parent_company}
          as   : "parent_company_details"
        }
      ]
    } as $subsidiary_table_1
  }

  response = $subsidiary_table_1
}