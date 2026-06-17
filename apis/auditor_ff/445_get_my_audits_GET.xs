query get_my_audits verb=GET {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
  }

  stack {
    db.query audit {
      where = $db.audit.auditor_id == $auth.id || $db.audit.override == $auth.id
      sort = {audit.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name", "city"]
          input : {companies_id: $output.companies_id}
        }
        {
          name  : "audit_types"
          output: ["type", "body"]
          input : {audit_types_id: $output.audit_types_id}
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "lead_auditor"
        }
        {
          name : "auditor"
          input: {auditor_id: $output.$this}
          as   : "secondary_auditors"
        }
        {
          name : "governing_body"
          input: {governing_body_id: $output.gov_body}
          as   : "governing_body"
        }
      ]
    } as $audit1
  }

  response = $audit1
}