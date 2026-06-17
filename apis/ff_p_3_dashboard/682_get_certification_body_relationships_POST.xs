query getCertificationBodyRelationships verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int certificationBody?
  }

  stack {
    db.query certificationBodyDetails {
      where = $db.certificationBodyDetails.certificationBody == $input.certificationBody
      return = {type: "list"}
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulator"
        }
      ]
    } as $certificationBodyDetails1
  }

  response = `($var.certificationBodyDetails1|is_empty)?[]:($var.certificationBodyDetails1.regulator|sort:name:text:true`
}