// Add subsidiary_table record
query subsidiary_table verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "subsidiary_table"
      override = {
        approved      : {hidden: true}
        rejected      : {hidden: true}
        created_at    : {hidden: true}
        subsidiary    : {hidden: false}
        parent_company: {hidden: false}
      }
    }
  }

  stack {
    db.add subsidiary_table {
      enforce_hidden_fields = false
      data = {
        parent_company: $input.parent_company
        subsidiary    : $input.subsidiary
        approved      : false
        rejected      : false
      }
    } as $subsidiary_table
  }

  response = $subsidiary_table
}