table notification_settings {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    bool ninety_days?=false
    text[] settings? filters=trim
    bool sixty_days?=false
    bool thirty_days?=false
    bool fourteen_days?=false
    bool seven_days?=false
    bool one_day?=false
    bool one_hour?=false
    bool holder?=false
    bool on?=false
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}