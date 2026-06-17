// Query all industries records
query industries verb=GET {
  api_group = "Certificates"

  input {
  }

  stack {
    db.query industries {
      return = {type: "list"}
    } as $industries
  }

  response = $industries
}