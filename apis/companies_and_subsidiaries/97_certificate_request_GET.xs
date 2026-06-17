// Query all certificate_request records
query certificate_request verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificate_request {
      return = {type: "list"}
    } as $certificate_request
  }

  response = $certificate_request
}