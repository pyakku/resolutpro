query auditorListCertificationBodies verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int auditor?
  }

  stack {
    db.query auditorDetails {
      where = $db.auditorDetails.auditor == $input.auditor
      return = {type: "list"}
      addon = [
        {
          name : "certificationBody"
          input: {certificationBody_id: $output.certificationBody}
          as   : "certificationBody"
        }
      ]
    } as $auditorDetails1
  }

  response = `($var.auditorDetails1|is_empty)?[]:($var.auditorDetails1.certificationBody|sort:name:text:true)`
}