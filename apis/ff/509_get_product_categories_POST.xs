query getProductCategories verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query isv_category {
      where = $db.isv_category.company == $input.company
      sort = {isv_category.category: "asc"}
      return = {type: "list"}
      output = ["id", "category"]
    } as $isv_category1
  }

  response = $isv_category1
}