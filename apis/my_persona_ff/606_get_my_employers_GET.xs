query getMyEmployers verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
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
      where = $db.contact_relationship.contact == $contacts1.id && $db.contact_relationship.employer == true
      sort = {contact_relationship.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
      ]
    } as $contact_relationship1
  }

  response = $contact_relationship1
}