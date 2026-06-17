table cyber_risk_assesment {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    text q1? filters=trim
    text q1_ans? filters=trim
    text q2? filters=trim
    text q2_ans? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}