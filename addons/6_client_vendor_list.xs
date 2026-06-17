addon client_vendor_list {
  input {
    int client_vendor_id? {
      table = "relationships"
    }
  }

  stack {
    db.query relationships {
      where = $db.relationships.id == $input.client_vendor_id
      return = {type: "list"}
    }
  }
}