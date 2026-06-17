query edit_contact verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
    text name? filters=trim
    text l_name? filters=trim
    text phone_number? filters=trim
  }

  stack {
    db.edit contacts {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        name        : $input.name
        l_name      : $input.l_name
        phone_number: $input.phone_number
      }
    
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