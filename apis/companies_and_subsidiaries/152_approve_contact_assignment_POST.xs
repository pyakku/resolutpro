query approve_contact_assignment verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    bool approval?=false
    text id? filters=trim
    text contact_id? filters=trim
  }

  stack {
    db.edit contact_relationship {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {approved: $input.approval}
    } as $contact_relationship_1
  
    db.query contact_relationship {
      where = $db.contact_relationship.contact == $input.contact_id
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $contact_relationship_2
  }

  response = $contact_relationship_2
}