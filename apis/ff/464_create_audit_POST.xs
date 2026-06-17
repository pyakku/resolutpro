query createAudit verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    dblink {
      table = "audit"
      override = {
        place                 : {hidden: false}
        appeal                : {hidden: true}
        due_by                : {hidden: false}
        failed                : {hidden: true}
        passed                : {hidden: true}
        comments              : {hidden: true}
        gov_body              : {hidden: true}
        override              : {hidden: true}
        policies              : {hidden: true}
        processes             : {hidden: true}
        auditor_id            : {hidden: false}
        created_at            : {hidden: true}
        acknowledged          : {hidden: true}
        certificates          : {hidden: true}
        companies_id          : {hidden: false}
        completed_on          : {hidden: true}
        audit_types_id        : {hidden: false}
        client_contact        : {hidden: false}
        action_comments       : {hidden: true}
        action_required       : {hidden: true}
        secondary_auditors    : {hidden: true}
        client_contact_contact: {hidden: false}
      }
    }
  }

  stack {
    db.add audit {
      enforce_hidden_fields = false
      data = {
        companies_id          : $input.companies_id
        auditor_id            : $input.auditor_id
        desc                  : $input.desc
        due_by                : $input.due_by
        audit_types_id        : $input.audit_types_id
        place                 : $input.place
        client_contact        : $input.client_contact
        client_contact_contact: $input.client_contact_contact
        client_contact_phone  : $input.client_contact_phone
        address1              : $input.address1
        address2              : $input.address2
        governingBody         : $input.governingBody
        documents             : $input.documents
      }
    } as $audit_2
  
    db.query audit {
      where = $db.audit.companies_id == $input.companies_id
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
      field_value = $input.companies_id
      output = ["Company_Name"]
    } as $company
  
    db.get audit_types {
      field_name = "id"
      field_value = $input.audit_types_id
    } as $audit_type
  
    db.get auditor {
      field_name = "id"
      field_value = $input.auditor_id
    } as $auditor
  
    conditional {
      if ($auditor.code|is_empty) {
        api.request {
          url = $env.emailBase
            |concat:"createAuditEmailToAuditor.php":""
          method = "POST"
          params = {}
            |set:"email":$auditor.email
            |set:"firstName":$auditor.first_name
            |set:"governingBody":$input.governingBody
            |set:"auditDescription":$input.desc
            |set:"companyName":$company.Company_Name
            |set:"auditStartTime":($input.due_by|format_timestamp:"F jS, Y":"UTC")
            |set:"contactFirstName":$input.client_contact
            |set:"contactLastName":""
            |set:"contactEmail":$input.client_contact_contact
            |set:"contactPhone":$input.client_contact_phone
            |set:"companyAddress":($input.address1
              |concat:$input.address2:", "
              |concat:$input.place:", "
            )
            |set:"needsPassword":false
            |set:"passwordLink":""
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      }
    
      else {
        api.request {
          url = $env.emailBase
            |concat:"createAuditEmailToAuditor.php":""
          method = "POST"
          params = {}
            |set:"email":$auditor.email
            |set:"firstName":$auditor.first_name
            |set:"governingBody":$input.governingBody
            |set:"auditDescription":$input.desc
            |set:"companyName":$company.Company_Name
            |set:"auditStartTime":($input.due_by|format_timestamp:"F jS, Y":"UTC")
            |set:"contactFirstName":$input.client_contact
            |set:"contactLastName":""
            |set:"contactEmail":$input.client_contact_contact
            |set:"contactPhone":$input.client_contact_phone
            |set:"companyAddress":($input.address1
              |concat:$input.address2:", "
              |concat:$input.place:", "
            )
            |set:"needsPassword":true
            |set:"passwordLink":("https://itrackersignup.p3audit.com/emailAPIs/sign_up_auditor_from_mail.php?suid="|concat:$auditor.code:"")
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      }
    }
  
    !api.request {
      url = $env.emailBase
        |concat:"assign_audit_mail.php":""
      method = "POST"
      params = {}
        |set:"email":$auditor.email
        |set:"company":$company.Company_Name
        |set:"f_name":$auditor.first_name
        |set:"date":($input.due_by|format_timestamp:"F jS, Y":"UTC")
        |set:"audit":$audit_type.type
      headers = []
        |push:"Content-Type: application/json"
      verify_host = false
      verify_peer = false
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log_1
  }

  response = {
    audits     : $audit_1
    audit_types: $audit_types_1
    auditors   : $auditor_1
  }
}