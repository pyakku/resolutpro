addon parent_company {
  input {
    int companies_id? {
      table = "companies"
    }
  }

  stack {
    db.query companies {
      where = $db.companies.id == $input.companies_id
      return = {type: "single"}
    }
  }
}