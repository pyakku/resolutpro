// Edit contact_relationship record
query "contact_relationship/{contact_relationship_id}" verb=POST {
  api_group = "Certificates"

  input {
    int contact_relationship_id? filters=min:1
    dblink {
      table = "contact_relationship"
    }
  }

  stack {
    db.edit contact_relationship {
      field_name = "id"
      field_value = $input.contact_relationship_id
      enforce_hidden_fields = false
      data = {}
    } as $contact_relationship
  }

  response = $contact_relationship
}