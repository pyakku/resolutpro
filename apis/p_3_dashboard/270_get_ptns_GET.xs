query get_ptns verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query relationships {
      sort = {relationships.PTN_no: "asc"}
      return = {type: "list"}
    } as $relationships_1
  }

  response = $relationships_1
}