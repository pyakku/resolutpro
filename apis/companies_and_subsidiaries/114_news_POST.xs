// Add news record
query news verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "news"
    }
  }

  stack {
    db.add news {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $news
  }

  response = $news
}