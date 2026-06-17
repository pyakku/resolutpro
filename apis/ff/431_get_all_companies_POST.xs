query get_all_companies verb=POST {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.test == false && $db.companies.individual == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name  : "countries"
          output: ["Name"]
          input : {countries_id: $output.country_code}
          as    : "country"
        }
        {
          name  : "functions"
          output: ["function"]
          input : {functions_id: $output.$this}
          as    : "functions"
        }
      ]
    } as $companies1
  }

  response = $companies1
}