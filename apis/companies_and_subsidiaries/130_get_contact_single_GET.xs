query get_contact_single verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
  }

  stack {
    db.get contacts {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $contacts_1
  }

  response = $contacts_1
}