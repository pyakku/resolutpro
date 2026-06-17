query cert_types verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificate_types {
      return = {type: "list"}
    } as $certificate_types_1
  }

  response = $certificate_types_1
}