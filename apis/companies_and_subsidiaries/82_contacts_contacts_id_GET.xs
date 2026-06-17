// Get contacts record
query "contacts/{contacts_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int contacts_id? filters=min:1
  }

  stack {
    db.get contacts {
      field_name = "id"
      field_value = $input.contacts_id
    } as $contacts
  
    precondition ($contacts != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $contacts
}