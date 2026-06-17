query allAudits verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query audit_types {
      sort = {audit_types.type: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.$this}
          as   : "documentsRequired"
        }
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulatorDetails"
        }
      ]
    } as $audit_types1
  }

  response = $audit_types1
}