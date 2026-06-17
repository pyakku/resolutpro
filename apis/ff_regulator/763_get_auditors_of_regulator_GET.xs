query getAuditorsOfRegulator verb=GET {
  api_group = "FFRegulator"
  auth = "regulator"

  input {
  }

  stack {
    db.query certificationBodyDetails {
      where = $db.certificationBodyDetails.regulator == $auth.id
      return = {type: "list"}
    } as $certificationBodyDetails1
  
    conditional {
      if (($certificationBodyDetails1|is_empty) || ($certificationBodyDetails1.certificationBody|is_empty)) {
        var $auditorDetails1 {
          value = []
        }
      }
    
      else {
        db.query auditorDetails {
          where = $db.auditorDetails.certificationBody in $certificationBodyDetails1.certificationBody
          return = {type: "list"}
          addon = [
            {
              name  : "auditor"
              output: [
                "id"
                "created_at"
                "first_name"
                "middle_name"
                "last_name"
                "email"
                "city"
                "country"
                "phone"
                "code"
                "image"
                "independent"
                "employed"
              ]
              input : {auditor_id: $output.auditor}
              as    : "auditor"
            }
            {
              name  : "certificationBody"
              output: ["name"]
              input : {certificationBody_id: $output.certificationBody}
            }
          ]
        } as $auditorDetails1
      }
    }
  }

  response = $auditorDetails1
}