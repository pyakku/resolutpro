query add_isv_category verb=POST {
  api_group = "products"

  input {
    text company_id? filters=trim
    text isv? filters=trim
  }

  stack {
    db.add isv_category {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        company   : $input.company_id|to_int
        category  : $input.isv
      }
    } as $isv_category_2
  
    db.query isv_category {
      where = $db.isv_category.company == $input.company_id
      sort = {isv_category.category: "asc"}
      return = {type: "list"}
    } as $isv_category_1
  }

  response = $isv_category_1
}