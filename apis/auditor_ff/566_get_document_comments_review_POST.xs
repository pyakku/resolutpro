query getDocumentCommentsReview verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
      output = [
        "documents.document"
        "documents.comment"
        "documents.viewedOn"
        "documents.rejected"
        "documents.approved"
      ]
    
      addon = [
        {
          name  : "myDocuments"
          output: ["document", "nameUA"]
          input : {myDocuments_id: $output.document}
          addon : [
            {
              name  : "documents"
              output: ["documentName"]
              input : {documents_id: $output.document}
            }
          ]
          as    : "documents.docDetails"
        }
      ]
    } as $audit1
  }

  response = $audit1
}