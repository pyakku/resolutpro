table auditor {
  auth = true

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text first_name? filters=trim
    text middle_name? filters=trim
    text last_name? filters=trim
    text email? filters=trim
    password password? {
      visibility = "internal"
    }
  
    text city? filters=trim
    text country? filters=trim
    text phone? filters=trim
    text code? filters=trim
    text? image?
    bool independent?
    bool employed?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}