query get_roles verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contact"
        }
      ]
    } as $contact_relationship_1
  }

  response = $contact_relationship_1
}