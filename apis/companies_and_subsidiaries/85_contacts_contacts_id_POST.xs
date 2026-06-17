// Edit contacts record
query "contacts/{contacts_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int contacts_id? filters=min:1
    dblink {
      table = "contacts"
    }
  }

  stack {
    db.edit contacts {
      field_name = "id"
      field_value = $input.contacts_id
      enforce_hidden_fields = false
      data = {}
    } as $contacts
  }

  response = $contacts
}