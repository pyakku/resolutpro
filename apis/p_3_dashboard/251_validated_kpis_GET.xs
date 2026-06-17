query validated_kpis verb=GET {
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
    
      where = $db.kpi.pass == true
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
        {name: "user", input: {user_id: $output.user}, as: "user"}
      ]
    } as $kpi_1
  }

  response = $kpi_1
}