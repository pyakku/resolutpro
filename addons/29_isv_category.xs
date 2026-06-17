addon isv_category {
  input {
    int isv_category_id? {
      table = "isv_category"
    }
  }

  stack {
    db.query isv_category {
      where = $db.isv_category.id == $input.isv_category_id
      return = {type: "single"}
    }
  }
}