table function_request {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int requested_by? {
      table = "companies"
    }
  
    int requested_to? {
      table = "companies"
    }
  
    int function? {
      table = "functions"
    }
  
    bool rejected?=false
    bool accepted?=false
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}