table other_certificates {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company_id? {
      table = "companies"
    }
  
    text details? filters=trim
    attachment? document?
    text auth_body? filters=trim
    int holder? {
      table = "contacts"
    }
  
    text? last_test_date?
    text test_auditor? filters=trim
    date? issued_date?
    date? expiry_date?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}