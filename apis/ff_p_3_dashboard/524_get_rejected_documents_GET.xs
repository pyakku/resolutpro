query getRejectedDocuments verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.rejected == true
      return = {type: "list"}
      addon = [
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
        {
          name : "documents"
          input: {documents_id: $output.document}
          addon: [
            {
              name  : "documentClassification"
              output: ["classification"]
              input : {documentClassification_id: $output.documentClassification}
            }
            {
              name  : "document_types"
              output: ["type"]
              input : {document_types_id: $output.documentType}
            }
          ]
          as   : "document"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holderContact}
          as   : "holderContact"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.holder_company}
          as   : "holder_company"
        }
      ]
    } as $myDocuments1
  
    var.update $myDocuments1 {
      value = $myDocuments1|sort:"Company_Name":"itext":true
    }
  }

  response = $myDocuments1
}