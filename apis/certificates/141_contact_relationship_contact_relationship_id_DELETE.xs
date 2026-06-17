// Delete contact_relationship record.
query "contact_relationship/{contact_relationship_id}" verb=DELETE {
  api_group = "Certificates"

  input {
    int contact_relationship_id? filters=min:1
  }

  stack {
    db.del contact_relationship {
      field_name = "id"
      field_value = $input.contact_relationship_id
    }
  }

  response = null
}