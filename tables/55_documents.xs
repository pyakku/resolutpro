table documents {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Certification name
    text documentName? filters=trim
  
    int documentClassification? {
      table = "documentClassification"
    }
  
    int documentType? {
      table = "document_types"
    }
  
    // Certificate description
    text desc? filters=trim
  
    text details? filters=trim
    image? logo?
    bool approved?=false
    int addedBy? {
      table = "p3DashboardUser"
    }
  
    bool show?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}