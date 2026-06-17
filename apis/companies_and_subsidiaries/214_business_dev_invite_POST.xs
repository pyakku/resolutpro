query business_dev_invite verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company? filters=trim
    text user? filters=trim
    text address? filters=trim
    text phone? filters=trim
    text email? filters=trim
    text city? filters=trim
    text country? filters=trim
    text first_name? filters=trim
    text last_name? filters=trim
    text ref_first_name? filters=trim
    text ref_last_name? filters=trim
    text ref_email? filters=trim
  }

  stack {
    db.add business_dev_invites {
      enforce_hidden_fields = false
      data = {
        created_at  : "now"
        user        : $input.user|to_int
        company_name: $input.company
        address     : $input.address
        phone       : $input.phone
        email       : $input.email
        city        : $input.city
        country     : $input.country
        first_name  : $input.first_name
        last_name   : $input.last_name
      }
    } as $business_dev_invites_1
  
    db.query business_dev_invites {
      where = $db.business_dev_invites.user == $input.user
      return = {type: "list"}
      addon = [
        {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
      ]
    } as $business_dev_invites_2
  }

  response = $business_dev_invites_2
}