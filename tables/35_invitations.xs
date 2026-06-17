table invitations {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    int invited_user? {
      table = "user"
    }
  
    int invited_company? {
      table = "companies"
    }
  
    int inviting_user? {
      table = "user"
    }
  
    int relationship? {
      table = "relationships"
    }
  
    text invited_company_name? filters=trim
    text email? filters=trim
    text contact? filters=trim
    timestamp? last_email_sent?
    bool accepted?=false
    json last_email_res?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}