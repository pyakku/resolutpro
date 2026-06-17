table user {
  auth = true

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text name
    text l_name? filters=trim
    email? email
    password? password filters=min:8|minAlpha:1|minDigit:1 {
      visibility = "internal"
    }
  
    // Company Id to link to the company table
    text user_id
  
    text profile_img? filters=trim
    text language? filters=trim
    text date_format? filters=trim
    bool is_admin?=false
    int plan? {
      table = "plan"
    }
  
    bool business_dev?=false
    text[] completed_walkthrough?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {
      type : "btree|unique"
      field: [{name: "xdo.email", op: "asc"}]
    }
  ]
}