query contacts_pending_verification verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company_id?
  }

  stack {
    db.query contacts {
      where = $db.contacts.created_by == $input.company_id && $db.contacts.approved == false
      sort = {contacts.name: "asc"}
      return = {type: "list"}
    } as $contacts1
  }

  response = $contacts1
}