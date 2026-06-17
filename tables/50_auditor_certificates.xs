table auditor_certificates {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int auditor_id? {
      table = "auditor"
    }
  
    text certificate_name? filters=trim
    date? issued?
    date? expiry?
    text issuer? filters=trim
    attachment? file?
    bool p3_validated?
    date? validation_date?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}