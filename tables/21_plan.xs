table plan {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text plan_name? filters=trim
    int free_docs?
    int free_ptns?
    text extra_ptn_item_code? filters=trim
    text extra_doc_item_code? filters=trim
    text code? filters=trim
    text price? filters=trim
    int pricePerMonth?
    int pricePerYear?
    text desc? filters=trim
    text[] features? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}