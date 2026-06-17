table companies {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text Company_Name? filters=trim
    text company_reg? filters=trim
    text created_by filters=trim
    int[] functions? {
      table = "functions"
    }
  
    bool is_sub?=false
    bool test?=false
    text email? filters=trim
    int created_by_user? {
      table = "user"
    }
  
    text industry? filters=trim
    int[] industryTableLink? {
      table = "industries"
    }
  
    text phone_number?
    text city? filters=trim
    text state? filters=trim
    text postal_code?
    text country? filters=trim
    text no_of_employees?
    text revenue?
    int country_code? {
      table = "countries"
    }
  
    int[] functions_inactive? {
      table = "functions"
    }
  
    text profile_link? filters=trim
    int plan? {
      table = "plan"
    }
  
    text onetrust? filters=trim
    text verifier_email? filters=trim
    text verifier_name? filters=trim
    enum mgt_report_frequency?=monthly {
      values = ["monthly", "15days"]
    }
  
    bool verified?=false
    timestamp? verified_on?
    bool p3_managed?
    bool preloaded?
    int[] regulator? {
      table = "regulator"
    }
  
    bool individual?
    bool markedForDeletion?
    text SAPCGrade? filters=trim
    timestamp? sapcInspectioDate?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}