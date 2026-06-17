query auditDetails verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name", "phone_number", "city", "state"]
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