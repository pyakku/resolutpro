table certificationBody {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int reg_program_owner? {
      table = "regulator"
    }
  
    text name? filters=trim
    text address? filters=trim
    text email? filters=trim
    password password? {
      visibility = "internal"
    }
  
    text code? filters=trim
    text member_name? filters=trim
    text designation? filters=trim
    text phone? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}