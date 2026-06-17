// Get contact_relationship record
query "contact_relationship/{contact_relationship_id}" verb=GET {
  api_group = "Certificates"

  input {
    int contact_relationship_id? filters=min:1
  }

  stack {
    db.get contact_relationship {
      field_name = "id"
      field_value = $input.contact_relationship_id
    } as $contact_relationship
  
    precondition ($contact_relationship != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $contact_relationship
}