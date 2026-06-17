table my_policies {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    int policies_id? {
      table = "policies"
    }
  
    attachment? document?
    date? validation_date?
    bool global_ack?=false
    text validation_comment? filters=trim
    date? date?
    date? renewal_date?
    int user? {
      table = "user"
    }
  
    bool archived?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}