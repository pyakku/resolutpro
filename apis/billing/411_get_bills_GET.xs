query get_bills verb=GET {
  api_group = "Billing"

  input {
  }

  stack {
    db.query billing {
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
      ]
    } as $billing_1
  }

  response = $billing_1
}