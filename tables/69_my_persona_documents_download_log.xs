table myPersonaDocumentsDownloadLog {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int user? {
      table = "user"
    }
  
    int document? {
      table = "myDocuments"
    }
  
    int company? {
      table = "companies"
    }
  
    text email? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}