query checkCategoryExists verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text category? filters=trim
    int company?
  }

  stack {
    db.query isv_category {
      where = $db.isv_category.company == $input.company && $db.isv_category.category == $input.category
      return = {type: "exists"}
    } as $isv_category1
  }

  response = {exists: $isv_category1}
}