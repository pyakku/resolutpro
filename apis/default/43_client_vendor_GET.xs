// Query all client_vendor records
query client_vendor verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query relationships {
      return = {type: "list"}
    } as $client_vendor
  }

  response = $client_vendor
}