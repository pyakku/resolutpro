query getPoliciesToAcknowledge verb=POST {
  api_group = "Policy Acknowledgement FF"
  auth = "user"

  input {
    int companyID?
  }

  stack {
    db.query documentAcknowledgement {
      where = $db.documentAcknowledgement.acknowlegedBy == $input.companyID
      sort = {documentAcknowledgement.acknowledged: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.myDocument}
          addon: [
            {
              name : "documents"
              input: {documents_id: $output.document}
              as   : "document"
            }
          ]
          as   : "myDocument"
        }
        {
          name : "companies"
          input: {companies_id: $output.owner}
          as   : "owner"
        }
      ]
    } as $documentAcknowledgement1
  
    array.filter ($documentAcknowledgement1) if ($this.myDocument.validated && $this.myDocument.archived == false && $this.myDocument.markedForDeletion == false) as $documentAcknowledgement1
  }

  response = $documentAcknowledgement1
}