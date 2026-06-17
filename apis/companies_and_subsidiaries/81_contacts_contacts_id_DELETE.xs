// Delete contacts record.
query "contacts/{contacts_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int contacts_id? filters=min:1
  }

  stack {
    db.del contacts {
      field_name = "id"
      field_value = $input.contacts_id
    }
  }

  response = null
}