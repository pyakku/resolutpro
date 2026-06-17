query check_email verb=POST {
  api_group = "7122022"

  input {
    text email? filters=trim
  }

  stack {
    db.query contacts {
      where = ($db.contacts.email|to_lower) == ($input.email|to_lower)
      return = {type: "exists"}
    } as $contacts_1
  }

  response = $contacts_1
}