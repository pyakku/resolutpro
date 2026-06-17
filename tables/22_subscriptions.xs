table subscriptions {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    int user_id? {
      table = "user"
    }
  
    int plan? {
      table = "plan"
    }
  
    bool active?=false
    text subscription_id? filters=trim
    text hosted_page_id? filters=trim
    int[] addon_user? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}