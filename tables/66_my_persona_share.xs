table myPersonaShare {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int myDocument? {
      table = "myDocuments"
    }
  
    int company? {
      table = "companies"
    }
  
    timestamp? stoppedOn?
    bool active?
    bool approvedByReciepent?
    text name? filters=trim
    text email? filters=trim
    text lName? filters=trim
    int shareLink? {
      table = "share_audits"
    }
  
    bool shareByEmail?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}