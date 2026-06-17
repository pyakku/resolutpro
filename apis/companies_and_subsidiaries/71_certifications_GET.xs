// Query all certifications records
query certifications verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query "" {
      return = {type: "list"}
    } as $certifications
  }

  response = $certifications
}