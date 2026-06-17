query add_p3_managed_companyFF verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text name? filters=trim
    text industry? filters=trim
    text city? filters=trim
    text reg? filters=trim
    text state? filters=trim
    text phone? filters=trim
    text country_name? filters=trim
    int country?
    text email? filters=trim
  }

  stack {
    db.add companies {
      enforce_hidden_fields = false
      data = {
        created_at     : "now"
        Company_Name   : $input.name
        company_reg    : $input.reg
        created_by     : "P3001001290"
        is_sub         : false
        test           : false
        email          : $input.email
        created_by_user: 202
        industry       : $input.industry
        phone_number   : $input.phone
        city           : $input.city
        state          : $input.state
        country        : $input.country_name
        country_code   : $input.country
        plan           : 9
        verified       : true
        p3_managed     : true
        preloaded      : true
      }
    } as $companies_2
  
    db.add subscriptions {
      enforce_hidden_fields = false
      data = {
        created_at     : "now"
        company        : $companies_2.id
        user_id        : 202
        plan           : 9
        active         : true
        subscription_id: "199Z29SoSs5OrYI"
      }
    } as $subscriptions_1
  
    db.query companies {
      where = $db.companies.p3_managed == true
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_details"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}