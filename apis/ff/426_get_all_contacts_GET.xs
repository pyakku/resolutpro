query get_all_contacts verb=GET {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query contacts {
      sort = {contacts.name: "asc", contacts.l_name: "asc"}
      return = {type: "list"}
    } as $contacts
  }

  response = $contacts
}