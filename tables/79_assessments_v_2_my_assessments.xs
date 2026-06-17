table assessmentsV2MyAssessments {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int question? {
      table = "assessmentsV2questions"
    }
  
    bool checked?
    timestamp? lastCheckedOn?
    int company? {
      table = "companies"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}