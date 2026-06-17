query audit_page_load verb=POST {
  api_group = "audits"

  input {
    text company? filters=trim
  }

  stack {
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
  }

  response = {
    audits     : $audit_1
    audit_types: $audit_types_1
    auditors   : $auditor_1
  }
}