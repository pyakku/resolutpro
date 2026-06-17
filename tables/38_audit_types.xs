table audit_types {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text type? filters=trim
    text body? filters=trim
    int regulator? {
      table = "regulator"
    }
  
    int[]? country? {
      table = "countries"
    }
  
    int[] documentsRequired? {
      table = "documents"
    }
  
    int[] assessmentsRequired? {
      table = "assessmentsV2"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}