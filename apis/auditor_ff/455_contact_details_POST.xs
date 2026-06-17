query contactDetails verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
    int contact?
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.contact == $input.contact && $db.contact_relationship.company == $input.company
      return = {type: "single"}
    } as $contact_relationship1
  }

  response = $contact_relationship1
}