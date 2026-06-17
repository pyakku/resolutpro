query pending_validations_kpis verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query kpi {
      join = {
        required_certificates: {
          table: "required_certificates"
          where: $db.kpi.id == $db.required_certificates.sla_extender
        }
      }
    
      where = $db.kpi.pass == false && ($db.kpi.ack_required_cert == 0 || $db.kpi.ack_required_cert == null) && ($db.kpi.ack_other_cert == 0 || $db.kpi.ack_other_cert == null)
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