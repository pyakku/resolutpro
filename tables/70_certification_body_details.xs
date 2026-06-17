table certificationBodyDetails {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int certificationBody? {
      table = "certificationBody"
    }
  
    int regulator? {
      table = "regulator"
    }
  
    text membershipDetails? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}