query audit_by_date_for_popup verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text date? filters=trim
  }

  stack {
    db.query audit {
      where = $db.audit.due_by == $input.date && ($db.audit.auditor_id == $auth.id || $db.audit.override == $auth.id)
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
        {
          name  : "audit_types"
          output: ["type"]
          input : {audit_types_id: $output.audit_types_id}
        }
      ]
    } as $audit1
  }

  response = $audit1
}