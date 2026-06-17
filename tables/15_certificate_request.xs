table certificate_request {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int requested_by? {
      table = "user"
    }
  
    text c_name? filters=trim
    text c_desc? filters=trim
    text? attachment?
    int requested_by_company? {
      table = "companies"
    }
  
    int accepted_certificate? {
      table = "certificates"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}