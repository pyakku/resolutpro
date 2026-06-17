query getCertificationBodies verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query certificationBody {
      sort = {certificationBody.name: "asc"}
      return = {type: "list"}
    } as $certificationBody1
  }

  response = $certificationBody1
}