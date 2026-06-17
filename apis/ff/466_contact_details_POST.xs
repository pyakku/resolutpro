query contactDetails verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    int contact?
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.contact == $input.contact && $db.contact_relationship.company == $input.company
      return = {type: "single"}
      addon = [
        {
          name  : "contacts"
          output: ["name", "l_name", "email", "phone_number"]
          input : {contacts_id: $output.contact}
        }
      ]
    } as $contact_relationship1
  
    conditional {
      if ($contact_relationship1|is_empty) {
        db.get contacts {
          field_name = "id"
          field_value = $input.contact
        } as $contact_relationship1
      }
    }
  }

  response = $contact_relationship1
}