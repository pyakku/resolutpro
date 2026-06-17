table employees {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    text f_name? filters=trim
    text m_name? filters=trim
    text l_name? filters=trim
    text role? filters=trim
    date? dob?
    date? doj?
    text email? filters=trim
    text phone? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}