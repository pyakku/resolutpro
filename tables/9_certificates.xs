table certificates {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Certification name
    text Certificate_Name? filters=trim
  
    int type? {
      table = "certificate_types"
    }
  
    // Certificate description
    text Certificate_Desc? filters=trim
  
    text details? filters=trim
    text q1? filters=trim
    text q2? filters=trim
    text q3? filters=trim
    text q4? filters=trim
    text q5? filters=trim
    image? logo?
    bool approved?=false
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}