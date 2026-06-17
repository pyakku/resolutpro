query edit_company_record verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "companies"
      override = {
        city              : {hidden: false}
        plan              : {hidden: false}
        test              : {hidden: true}
        state             : {hidden: false}
        is_sub            : {hidden: true}
        country           : {hidden: false}
        revenue           : {hidden: false}
        industry          : {hidden: false}
        onetrust          : {hidden: false}
        functions         : {hidden: true}
        created_at        : {hidden: true}
        created_by        : {hidden: true}
        company_reg       : {hidden: true}
        postal_code       : {hidden: false}
        Company_Name      : {hidden: false}
        country_code      : {hidden: true}
        phone_number      : {hidden: false}
        profile_link      : {hidden: false}
        created_by_user   : {hidden: true}
        no_of_employees   : {hidden: false}
        functions_inactive: {hidden: true}
      }
    }
  
    text company_id? filters=trim
    text onetrust? filters=trim
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.company_id
      enforce_hidden_fields = false
      data = {
        Company_Name   : $input.Company_Name
        industry       : $input.industry
        phone_number   : $input.phone_number
        city           : $input.city
        state          : $input.state
        postal_code    : $input.postal_code
        no_of_employees: $input.no_of_employees
        revenue        : $input.revenue
        country_code   : $input.country|to_int
        profile_link   : $input.profile_link
        onetrust       : $input.onetrust
      }
    } as $companies_1
  }

  response = $companies_1
}