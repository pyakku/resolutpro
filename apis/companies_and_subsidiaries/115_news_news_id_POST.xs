// Edit news record
query "news/{news_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int news_id? filters=min:1
    dblink {
      table = "news"
    }
  }

  stack {
    db.edit news {
      field_name = "id"
      field_value = $input.news_id
      enforce_hidden_fields = false
      data = {}
    } as $news
  }

  response = $news
}