// Query all certificates_needed records
query certificates_needed verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificates_needed {
      return = {type: "list"}
    } as $certificates_needed
  }

  response = $certificates_needed
}