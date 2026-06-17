query company_page verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    function.run company_and_owner_details as $companies_list
    function.run required_certificates as $required_certificates
    function.run current_company_subs {
      input = {company_id: $input.company_id}
    } as $my_subs
  
    function.run get_my_relationships {
      input = {id: $input.company_id}
    } as $my_relationships
  
    db.query countries {
      return = {type: "list"}
    } as $countries
  
    db.query functions {
      return = {type: "list"}
    } as $functions
  }

  response = {
    companies_list       : $companies_list
    required_certificates: $required_certificates
    my_subs              : $my_subs
    my_relationships     : $my_relationships
    countries            : $countries
    functions            : $functions
  }
}