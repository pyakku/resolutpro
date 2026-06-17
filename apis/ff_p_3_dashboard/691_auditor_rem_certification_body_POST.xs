query auditorRemCertificationBody verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int auditor?
    int certificationBody?
  }

  stack {
    db.bulk.delete auditorDetails {
      where = $db.auditorDetails.auditor == $input.auditor && $db.auditorDetails.certificationBody == $input.certificationBody
    } as $auditorDetails1
  }

  response = $auditorDetails1
}