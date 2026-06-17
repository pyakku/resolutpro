table relationships {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text PTN_no?
    bool approved?=false
    int assigned_to? {
      table = "companies"
    }
  
    int assigned_by? {
      table = "companies"
    }
  
    int data_owner? {
      table = "companies"
    }
  
    int functions? {
      table = "functions"
    }
  
    int Country? {
      table = "countries"
    }
  
    text desc? filters=trim
    attachment? sla?
    bool terminated?
    text replaces? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}