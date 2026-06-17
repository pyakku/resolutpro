query set_audit_status_pass verb=POST {
  api_group = "auditor_dashboard"

  input {
    text audit_id? filters=trim
    text comment? filters=trim
    text place? filters=trim
  }

  stack {
    db.edit audit {
      field_name = "id"
      field_value = $input.audit_id
      enforce_hidden_fields = false
      data = {
        passed      : true
        failed      : false
        comments    : $input.comment
        completed_on: now
      }
    
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "user"
            }
          ]
          as   : "company"
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "auditor"
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit"
        }
      ]
    } as $audit_1
  
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
  
    !var $company_id {
      value = $audit_details.company.id
    }
  
    api.request {
      url = "https://p3audit.com/itracker/audit_complete_email.php"
      method = "POST"
      params = {}
        |set:"company":$audit_1.company.Company_Name
        |set:"f_name":$audit_1.company.user.name
        |set:"email_auditor":$audit_1.auditor.email
        |set:"email_client":$audit_1.company.user.email
        |set:"date":(now
          |format_timestamp:"D, d M Y":"UTC"
        )
        |set:"audit":$audit_1.audit.type
        |set:"status":"PASS"
        |set:"comment":$input.comment
        |set:"auditor":$audit_1.auditor.first_name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = {audit_details: $audit_details}
}