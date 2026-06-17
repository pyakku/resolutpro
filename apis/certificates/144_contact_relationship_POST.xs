// Add contact_relationship record
query contact_relationship verb=POST {
  api_group = "Certificates"

  input {
    dblink {
      table = "contact_relationship"
    }
  }

  stack {
    db.add contact_relationship {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $contact_relationship
  }

  response = $contact_relationship
}