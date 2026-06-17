query getContactRelationshipsToApprove verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.mypersona == true && $db.contact_relationship.approved == false && $db.contact_relationship.company == $input.company
      sort = {contact_relationship.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contactDetails"
        }
      ]
    } as $contact_relationship1
  }

  response = $contact_relationship1
}