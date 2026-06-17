query ptn_replaced_by verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text ptn_no? filters=trim
  }

  stack {
    db.get relationships {
      field_name = "replaces"
      field_value = $input.ptn_no
    } as $relationships_1
  }

  response = $relationships_1
}