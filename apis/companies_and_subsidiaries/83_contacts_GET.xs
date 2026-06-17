// Query all contacts records
query contacts verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query contacts {
      where = $db.contacts.approved == true
      sort = {contacts.name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.created_by}
          as   : "created_by"
        }
      ]
    } as $contacts
  }

  response = $contacts
}