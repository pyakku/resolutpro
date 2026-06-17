// Get news record
query "news/{news_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int news_id? filters=min:1
  }

  stack {
    db.get news {
      field_name = "id"
      field_value = $input.news_id
    } as $news
  
    precondition ($news != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $news
}