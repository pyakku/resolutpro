query auditorRemoveCertificationBody verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int auditor?
    int certificationBody?
  }

  stack {
    db.query auditorDetails {
      where = $db.auditorDetails.auditor == $input.auditor && $db.auditorDetails.certificationBody == $input.certificationBody
      return = {type: "exists"}
    } as $auditorDetails1
  
    conditional {
      if ($auditorDetails1) {
      }
    
      else {
        db.add auditorDetails {
          enforce_hidden_fields = false
          data = {
            created_at       : "now"
            auditor          : $input.auditor
            certificationBody: $input.certificationBody
          }
        } as $auditorDetails2
      }
    }
  }

  response = $auditorDetails1
}