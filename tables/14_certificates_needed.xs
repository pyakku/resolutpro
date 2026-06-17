table certificates_needed {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int functions_id? {
      table = "functions"
    }
  
    int countries_id? {
      table = "countries"
    }
  
    int certificates_id? {
      table = "certificates"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}