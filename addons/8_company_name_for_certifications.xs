addon company_name_for_certifications {
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