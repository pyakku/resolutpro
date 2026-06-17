query audit_page_details verb=POST {
  api_group = "auditor_dashboard"

  input {
    text audit_id? filters=trim
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.audit_id
      addon = [
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_type"
        }
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
      ]
    } as $audit_details
  
    var $company_id {
      value = $audit_details.company.id
    }
  }

  response = {audit_details: $audit_details}
}