query getAllRegulators verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query regulator {
      sort = {regulator.name: "asc"}
      return = {type: "list"}
    } as $regulator1
  }

  response = $regulator1
}