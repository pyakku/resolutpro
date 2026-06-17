query add_kpi_with_document verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "kpi"
      override = {
        ptn              : {hidden: false}
        pass             : {hidden: true}
        type             : {hidden: false}
        comments         : {hidden: true}
        document         : {hidden: true}
        alert_date       : {hidden: false}
        created_at       : {hidden: true}
        action_date      : {hidden: false}
        assigned_by      : {hidden: false}
        assigned_to      : {hidden: false}
        description      : {hidden: false}
        requirement      : {hidden: false}
        acknowledged     : {hidden: false}
        relationship     : {hidden: false}
        ack_other_cert   : {hidden: false}
        validation_date  : {hidden: true}
        ack_required_cert: {hidden: false}
      }
    }
  
    text cert_id? filters=trim
  }

  stack {
    db.add kpi {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        relationship     : $input.relationship
        type             : $input.type
        requirement      : $input.requirement
        description      : $input.description
        action_date      : $input.action_date
        alert_date       : $input.alert_date
        assigned_by      : $input.assigned_by
        assigned_to      : $input.assigned_to
        ack_required_cert: $input.cert_id|to_int
      }
    } as $kpi_1
  
    !db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id : $input.assigned_to
        active       : true
        self_attested: true
        sla_extender : $kpi_1.id
      }
    } as $required_certificates_1
  
    !db.query kpi {
      where = $db.kpi.relationship == $input.relationship
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
    
      where = $db.kpi.relationship == $input.relationship
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