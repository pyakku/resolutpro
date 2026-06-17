table assessmentsV2 {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text assessmentName? filters=trim
    int regulator? {
      table = "regulator"
    }
  
    int[] assessmentSections? {
      table = "assessmentsV2Sections"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}