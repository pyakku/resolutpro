query get_isv_categories verb=POST {
  api_group = "products"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query isv_category {
      where = $db.isv_category.company == $input.company_id
      sort = {isv_category.category: "asc"}
      return = {type: "list"}
    } as $isv_category_1
  }

  response = $isv_category_1
}