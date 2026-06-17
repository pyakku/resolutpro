query auditor_page_load verb=POST {
  api_group = "auditor_dashboard"

  input {
    text email? filters=trim
  }

  stack {
    db.get auditor {
      field_name = "email"
      field_value = $input.email
      addon = [
        {
          name : "governing_body"
          input: {governing_body_id: $output.$this}
          as   : "governing_body"
        }
      ]
    } as $auditor_details
  
    db.query audit {
      where = $db.audit.auditor_id == $auditor_details.id
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_type"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
      ]
    } as $audit_details
  }

  response = {
    auditor_details: $auditor_details
    audit_details  : $audit_details
  }
}