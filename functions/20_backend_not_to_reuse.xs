function backend_not_to_reuse {
  input {
  }

  stack {
    db.query companies {
      where = $db.companies.id > 388
      return = {type: "list"}
    } as $companies1
  
    foreach ($companies1) {
      each as $item {
        db.edit companies {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {functions: []|push:187}
        } as $companies2
      }
    }
  }

  response = $api1
}