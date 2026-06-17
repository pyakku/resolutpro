query all_associations_of_contact verb=POST {
  api_group = "Certificates"

  input {
    text contact? filters=trim
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.contact == $input.contact
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $contact_relationship_1
  }

  response = $contact_relationship_1
}