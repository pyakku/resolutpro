// Query all news records
query news verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query news {
      return = {type: "list"}
    } as $news
  }

  response = $news
}