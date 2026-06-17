query get_data verb=GET {
  api_group = "sign_upv3"

  input {
  }

  stack {
    db.query plan {
      return = {type: "list"}
    } as $plan_1
  
    db.query countries {
      return = {type: "list"}
    } as $countries_1
  
    db.query functions {
      return = {type: "list"}
    } as $functions_1
  
    db.query industries {
      return = {type: "list"}
    } as $industries_1
  
    db.query companies {
      where = $db.companies.test == false
      return = {type: "list"}
      output = ["id", "Company_Name"]
    } as $companies_1
  }

  response = {
    plans     : $plan_1
    countries : $countries_1
    functions : $functions_1
    industries: $industries_1
    companies : $companies_1
  }
}