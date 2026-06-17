table my_assessments {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int assessments_id? {
      table = "assessments"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    json company?
    json auditor?
    int auditor_id? {
      table = "auditor"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}