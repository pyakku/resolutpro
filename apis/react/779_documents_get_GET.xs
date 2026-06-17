query "documents/get" verb=GET {
  api_group = "react"
  auth = "user"

  input {
    text company_id? filters=trim
    int page?
    text search? filters=trim
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id && $db.myDocuments.nameUA includes? $input.search
      sort = {myDocuments.created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: 10, metadata: false}
      }
    } as $myDocuments1
  }

  response = $myDocuments1
}