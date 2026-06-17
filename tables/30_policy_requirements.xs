table policy_requirements {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text PTN? filters=trim
    int my_policies_id? {
      table = "my_policies"
    }
  
    int assigned_to? {
      table = "companies"
    }
  
    int originator? {
      table = "companies"
    }
  
    bool acknowledged?=false
    date? due_date?
    date? acknowledged_on?
    int relationships_id? {
      table = "relationships"
    }
  
    date? validation_date?
    bool pass?=false
    text comments? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}