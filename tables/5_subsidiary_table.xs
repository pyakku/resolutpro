table subsidiary_table {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int parent_company? {
      table = "companies"
    }
  
    int subsidiary? {
      table = "companies"
    }
  
    bool approved?=false
    bool rejected?=false
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}