table products {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int company? {
      table = "companies"
    }
  
    int isv? {
      table = "isv_category"
    }
  
    text product_name? filters=trim
    text version? filters=trim
    text other_identifiers? filters=trim
    int[] certificates? {
      table = "myDocuments"
    }
  
    text ECCN? filters=trim
    int co? {
      table = "required_certificates"
    }
  
    int coc? {
      table = "required_certificates"
    }
  
    int coa? {
      table = "required_certificates"
    }
  
    int[] third_party_processors? {
      table = "products"
    }
  
    text software_auditor? filters=trim
    timestamp? validated_on?
    bool is_software?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}