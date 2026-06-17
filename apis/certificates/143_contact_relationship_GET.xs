// Query all contact_relationship records
query contact_relationship verb=GET {
  api_group = "Certificates"

  input {
  }

  stack {
    db.query contact_relationship {
      return = {type: "list"}
    } as $contact_relationship
  }

  response = $contact_relationship
}