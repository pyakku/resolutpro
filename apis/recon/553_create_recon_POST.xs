query createRecon verb=POST {
  api_group = "Recon"
  auth = "user"

  input {
    int companyID?
    int[] documents?
  }

  stack {
    db.add DocumentRecon {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        company   : $input.companyID
        documents : $input.documents
        user      : $auth.id
      }
    } as $DocumentRecon1
  }

  response = $DocumentRecon1
}