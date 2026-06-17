table required_certificates {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    int certificates_id? {
      table = "certificates"
    }
  
    bool active?=false
    attachment? document?
    text product_name? filters=trim
    int holder? {
      table = "contacts"
    }
  
    int holder_company? {
      table = "companies"
    }
  
    timestamp? issued_date?
    timestamp? expiry_date?
    text issued_by? filters=trim
    timestamp? last_test_date?
    text test_auditor? filters=trim
    bool required_for_compliance?=false
    bool self_attested?=false
    bool remote_validation?=false
    bool p3_audited?=false
    int sla_extender? {
      table = "kpi"
    }
  
    timestamp? validated_on?
    text validation_comments? filters=trim
    bool rejected?
    timestamp? rejected_on?
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