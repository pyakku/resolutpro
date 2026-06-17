query GetAuditsHomePage verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query audit {
      where = $db.audit.companies_id == $input.company
      sort = {audit.created_at: "desc"}
      return = {type: "list"}
    } as $audit1
  }

  response = $audit1
}