query getCertificationBodiesAddAudit verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int auditType?
  }

  stack {
    db.get audit_types {
      field_name = "id"
      field_value = $input.auditType
    } as $audit_types1
  
    db.query certificationBodyDetails {
      where = $db.certificationBodyDetails.regulator == $audit_types1.regulator
      return = {type: "list"}
      addon = [
        {
          name : "certificationBody"
          input: {certificationBody_id: $output.certificationBody}
          as   : "certificationBody"
        }
      ]
    } as $certificationBodyDetails1
  
    var.update $certificationBodyDetails1 {
      value = $certificationBodyDetails1.certificationBody|sort:"name":"itext":true
    }
  }

  response = $certificationBodyDetails1
}