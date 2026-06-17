addon contacts {
  input {
    int contacts_id? {
      table = "contacts"
    }
  }

  stack {
    db.query contacts {
      where = $db.contacts.id == $input.contacts_id
      return = {type: "single"}
    }
  }
}