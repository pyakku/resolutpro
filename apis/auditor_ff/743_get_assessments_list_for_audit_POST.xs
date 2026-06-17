query getAssessmentsListForAudit verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    db.get audit_types {
      field_name = "id"
      field_value = $audit1.audit_types_id
    } as $audit_types1
  
    db.query assessmentsV2 {
      where = $db.assessmentsV2.id in $audit_types1.assessmentsRequired
      return = {type: "list"}
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulator"
        }
      ]
    } as $assessmentsV21
  }

  response = $assessmentsV21
}