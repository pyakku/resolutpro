query get_my_contacts verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query contacts {
      where = $db.contacts.created_by == $input.company_id
      return = {type: "list"}
    } as $contacts_1
  }

  response = $contacts_1
}