// Delete news record.
query "news/{news_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int news_id? filters=min:1
  }

  stack {
    db.del news {
      field_name = "id"
      field_value = $input.news_id
    }
  }

  response = null
}