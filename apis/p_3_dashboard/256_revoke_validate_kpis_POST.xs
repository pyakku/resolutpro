query revoke_validate_kpis verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    text user? filters=trim
  }

  stack {
    db.edit kpi {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        validation_date: now
        pass           : false
        user           : $input.user|to_int
      }
    } as $kpi_2
  
    db.query kpi {
      join = {
        required_certificates: {
          table: "required_certificates"
          where: $db.kpi.id == $db.required_certificates.sla_extender
        }
      }
    
      where = $db.kpi.pass == true && ($db.kpi.ack_required_cert == 0 || $db.kpi.ack_required_cert == null && $db.kpi.ack_other_cert == null || $db.kpi.ack_other_cert == 0)
      eval = {certificate: $db.required_certificates.document}
      return = {type: "list"}
      addon = [
        {
          name : "relationships"
          input: {relationships_id: $output.relationship}
          as   : "relationship"
        }
        {
          name : "companies"
          input: {companies_id: $output.assigned_by}
          as   : "assigned_by"
        }
        {
          name : "companies"
          input: {companies_id: $output.assigned_to}
          as   : "assigned_to"
        }
      ]
    } as $kpi_1
  }

  response = $kpi_1
}