table regulator {
  auth = true

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text name? filters=trim
    text email? filters=trim
    password password? {
      visibility = "internal"
    }
  
    int[] countries? {
      table = "countries"
    }
  
    int[] industries? {
      table = "industries"
    }
  
    bool allCountries?
    bool allIndustries?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}