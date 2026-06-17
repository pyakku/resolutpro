table share_audits {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    int[] certificates? {
      table = "required_certificates"
    }
  
    int[] policies? {
      table = "my_policies"
    }
  
    text f_name? filters=trim
    text l_name? filters=trim
    text email? filters=trim
    text controller? filters=trim
    timestamp? valid?
    int[] documents? {
      table = "myDocuments"
    }
  
    bool viewed?
    timestamp[]? sendHistory?
    bool myPersona?
    bool download?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}