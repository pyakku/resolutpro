query create_audit verb=POST {
  api_group = "audits"

  input {
    text company? filters=trim
    text audit_type? filters=trim
    text auditor? filters=trim
    date? due_date?
    text contact? filters=trim
    text contact_no? filters=trim
  }

  stack {
    db.add audit {
      enforce_hidden_fields = false
      data = {
        companies_id          : $input.company|to_int
        auditor_id            : $input.auditor|to_int
        due_by                : $input.due_date
        audit_types_id        : $input.audit_type|to_int
        client_contact        : $input.contact
        client_contact_contact: $input.contact_no
      }
    } as $audit_2
  
    db.query audit {
      where = $db.audit.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_types_id"
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "auditor_id"
        }
      ]
    } as $audit_1
  
    db.query audit_types {
      return = {type: "list"}
    } as $audit_types_1
  
    db.query auditor {
      return = {type: "list"}
    } as $auditor_1
  
    db.get companies {
      field_name = "id"
      field_value = $input.company
      output = ["Company_Name"]
    } as $company
  
    db.get auditor {
      field_name = "id"
      field_value = $input.auditor
    } as $auditor
  
    db.get audit_types {
      field_name = "id"
      field_value = $input.audit_type
    } as $audit_type
  
    api.request {
      url = "https://p3audit.com/itracker/assign_audit_mail.php"
      method = "POST"
      params = {}
        |set:"email":$auditor.email
        |set:"company":$company.Company_Name
        |set:"f_name":$auditor.first_name
        |set:"date":($input.due_date|format_timestamp:"F jS, Y":"UTC")
        |set:"audit":$audit_type.type
      headers = []
        |push:"Content-Type: application/json"
      verify_host = false
      verify_peer = false
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = {
    audits     : $audit_1
    audit_types: $audit_types_1
    auditors   : $auditor_1
  }
}