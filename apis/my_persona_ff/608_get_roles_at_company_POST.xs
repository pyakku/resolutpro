query getRolesAtCompany verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company && $db.contact_relationship.contact == $contacts1.id
      return = {type: "list"}
    } as $contact_relationship1
  }

  response = $contact_relationship1
}