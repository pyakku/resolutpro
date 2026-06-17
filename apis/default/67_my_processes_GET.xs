query my_processes verb=GET {
  api_group = "Default"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.created_by == $input.company_id
      return = {type: "list"}
    } as $client_vendor_1
  }

  response = $client_vendor_1
}