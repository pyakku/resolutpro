table documentAcknowledgement {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int myDocument? {
      table = "myDocuments"
    }
  
    int owner? {
      table = "companies"
    }
  
    int acknowlegedBy? {
      table = "companies"
    }
  
    bool acknowledged?
    timestamp? ackDate?
    text PTN? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}