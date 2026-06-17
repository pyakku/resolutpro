query get_kpi_details_ptn verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text rel? filters=trim
  }

  stack {
    !db.query kpi {
      where = $db.kpi.relationship == $input.rel
      return = {type: "list"}
      addon = [
        {
          name : "kpis_types"
          input: {kpis_types_id: $output.type}
          as   : "type"
        }
      ]
    } as $kpi_2
  
    !db.query kpi {
      join = {
        required_certificates: {
          table: "required_certificates"
          where: $db.required_certificates.sla_extender == $db.kpi.id
        }
      }
    
      where = $db.kpi.relationship == $input.rel
      eval = {kpi_document: $db.required_certificates.document}
      return = {type: "list"}
      addon = [
        {
          name : "kpis_types"
          input: {kpis_types_id: $output.type}
          as   : "type"
        }
      ]
    } as $kpi_2
  
    db.query kpi {
      join = {
        required_certificates: {
          table: "required_certificates"
          type : "left"
          where: $db.required_certificates.sla_extender == $db.kpi.id
        }
      }
    
      where = $db.kpi.ptn == $input.rel
      eval = {kpi_document: $db.required_certificates.document}
      return = {type: "list"}
      addon = [
        {
          name : "kpis_types"
          input: {kpis_types_id: $output.type}
          as   : "type"
        }
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.ack_required_cert}
          addon: [
            {
              name : "certificates"
              input: {certificates_id: $output.certificates_id}
              as   : "certificates_id"
            }
          ]
          as   : "ack_required_cert"
        }
      ]
    } as $kpi_2
  }

  response = $kpi_2
}