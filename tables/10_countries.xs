table countries {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    text? Name?
    text country_code? filters=trim
    text currency? filters=trim
    text currency_code? filters=trim
    text area_code? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}