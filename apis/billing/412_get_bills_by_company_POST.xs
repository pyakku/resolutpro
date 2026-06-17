query get_bills_by_company verb=POST {
  api_group = "Billing"

  input {
    text company? filters=trim
  }

  stack {
    db.query billing {
      where = $db.billing.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
      ]
    } as $billing_1
  }

  response = $billing_1
}