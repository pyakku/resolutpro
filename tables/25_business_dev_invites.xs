table business_dev_invites {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int user? {
      table = "user"
    }
  
    text company_name? filters=trim
    text address? filters=trim
    text phone? filters=trim
    text email? filters=trim
    bool accepted?=false
    bool rejected?=false
    int plan? {
      table = "plan"
    }
  
    text city? filters=trim
    text country? filters=trim
    text first_name? filters=trim
    text last_name? filters=trim
    int responding_company? {
      table = "companies"
    }
  
    text ref_first_name? filters=trim
    text ref_last_name? filters=trim
    text ref_email? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}