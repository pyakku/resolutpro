query get_ptns_report_page verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_by == $input.company || $db.relationships.assigned_to == $input.company
      return = {type: "list"}
    } as $relationships_1
  }

  response = $relationships_1
}