query get_employees verb=POST {
  api_group = "certificates_new"

  input {
    text company? filters=trim
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company && $db.contact_relationship.approved == true
      return = {type: "list"}
      addon = [
        {
          name  : "contacts"
          output: ["name", "l_name"]
          input : {contacts_id: $output.contact}
        }
      ]
    } as $contact_relationship_1
  }

  response = $contact_relationship_1
}