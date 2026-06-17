table kpi {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int relationship? {
      table = "relationships"
    }
  
    int type? {
      table = "kpis_types"
    }
  
    text requirement? filters=trim
    text description? filters=trim
    date? action_date?
    date? alert_date?
    date? validation_date?
    bool pass?=false
    attachment? document?
    int assigned_by? {
      table = "companies"
    }
  
    int assigned_to? {
      table = "companies"
    }
  
    text comments? filters=trim
    int ack_required_cert? {
      table = "required_certificates"
    }
  
    int ack_other_cert? {
      table = "other_certificates"
    }
  
    bool acknowledged?=false
    text ptn? filters=trim
    int user? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}