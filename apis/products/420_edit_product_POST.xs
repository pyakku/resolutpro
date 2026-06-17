query edit_product verb=POST {
  api_group = "products"

  input {
    dblink {
      table = "products"
      override = {
        co                    : {hidden: true}
        coa                   : {hidden: true}
        coc                   : {hidden: true}
        isv                   : {hidden: false}
        ECCN                  : {hidden: false}
        company               : {hidden: true}
        created_at            : {hidden: true}
        product_name          : {hidden: false}
        validated_on          : {hidden: true}
        last_audit_date       : {hidden: true}
        software_auditor      : {hidden: true}
        third_party_processors: {hidden: false}
      }
    }
  
    text id? filters=trim
  }

  stack {
    db.edit products {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        isv                   : $input.isv
        product_name          : $input.product_name
        version               : $input.version
        other_identifiers     : $input.other_identifiers
        ECCN                  : $input.ECCN
        third_party_processors: $input.third_party_processors
        is_software           : $input.is_software
        certificates          : $input.certificates
      }
    } as $products1
  }

  response = "Done"
}