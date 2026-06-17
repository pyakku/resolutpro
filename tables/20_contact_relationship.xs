table contact_relationship {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int contact? {
      table = "contacts"
    }
  
    int company? {
      table = "companies"
    }
  
    text role? filters=trim
    bool approved?=false
    text approval_code? filters=trim
    bool mypersona?
    bool employer?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}