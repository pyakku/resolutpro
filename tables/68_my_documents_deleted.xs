table myDocumentsDeleted {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    int document? {
      table = "documents"
    }
  
    bool globalAck?
    attachment? file?
    text nameUA? filters=trim
    timestamp? issueDate?
    timestamp? expiryDate?
    timestamp? validationDate?
    int holderContact? {
      table = "contacts"
    }
  
    text issuedBy? filters=trim
    timestamp? lastTestDate?
    text testAuditor? filters=trim
    text validationComments? filters=trim
    int validatedBy? {
      table = "p3DashboardUser"
    }
  
    bool validated?
    bool rejected?
    bool active?
    int holder_company? {
      table = "companies"
    }
  
    bool archived?
    bool myPersona?
    enum mypersonaClassification? {
      values = [
        "Personal"
        "Financial"
        "Social"
        "Internal"
        "External"
        "Historical"
        "Work"
      ]
    }
  
    bool markedForDeletion?
    timestamp? deletedOn?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}