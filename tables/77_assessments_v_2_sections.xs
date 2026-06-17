table assessmentsV2Sections {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text sectionName? filters=trim
    int[] questionList? {
      table = "assessmentsV2questions"
    }
  
    int[] documents? {
      table = "documents"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}