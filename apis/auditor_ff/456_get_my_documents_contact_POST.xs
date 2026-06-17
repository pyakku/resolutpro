// Get All Documents of the current User
query getMyDocumentsContact verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
    int documentClassification?
    int contact?
  }

  stack {
    conditional {
      if ($input.documentClassification == 0) {
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true && $db.myDocuments.holderContact == $input.contact
          return = {type: "list"}
          addon = [
            {
              name : "documents"
              input: {documents_id: $output.document}
              addon: [
                {
                  name  : "document_types"
                  output: ["type"]
                  input : {document_types_id: $output.documentType}
                }
                {
                  name  : "documentClassification"
                  output: ["classification"]
                  input : {documentClassification_id: $output.documentClassification}
                }
              ]
              as   : "document"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.holder_company}
              as    : "holder_company"
            }
            {
              name : "contacts"
              input: {contacts_id: $output.holderContact}
              as   : "holderContact"
            }
          ]
        } as $myDocuments1
      
        !db.get contacts {
          field_name = "id"
          field_value = $input.contact
        } as $contacts1
      
        !db.get user {
          field_name = "email"
          field_value = $contacts1.email
        } as $user1
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.company == $input.company && $db.myPersonaShare.shareByEmail == false
          return = {type: "list"}
        } as $myPersonaShare1
      
        db.query myDocuments {
          where = $db.myDocuments.id in $myPersonaShare1.myDocument && $db.myDocuments.holderContact == $input.contact
          return = {type: "list"}
          addon = [
            {
              name : "documents"
              input: {documents_id: $output.document}
              addon: [
                {
                  name  : "document_types"
                  output: ["type"]
                  input : {document_types_id: $output.documentType}
                }
                {
                  name  : "documentClassification"
                  output: ["classification"]
                  input : {documentClassification_id: $output.documentClassification}
                }
              ]
              as   : "document"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.holder_company}
              as    : "holder_company"
            }
            {
              name : "contacts"
              input: {contacts_id: $output.holderContact}
              as   : "holderContact"
            }
          ]
        } as $myDocuments2
      
        var.update $myDocuments1 {
          value = $myDocuments1|merge:$myDocuments2
        }
      }
    
      else {
        db.query documents {
          where = $db.documents.documentClassification == $input.documentClassification
          return = {type: "list"}
        } as $documents1
      
        var.update $documents1 {
          value = $documents1.id
        }
      
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true && $db.myDocuments.document in $documents1 && $db.myDocuments.holderContact == $input.contact
          return = {type: "list"}
          addon = [
            {
              name : "documents"
              input: {documents_id: $output.document}
              addon: [
                {
                  name  : "document_types"
                  output: ["type"]
                  input : {document_types_id: $output.documentType}
                }
                {
                  name  : "documentClassification"
                  output: ["classification"]
                  input : {documentClassification_id: $output.documentClassification}
                }
              ]
              as   : "document"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.holder_company}
              as    : "holder_company"
            }
            {
              name : "contacts"
              input: {contacts_id: $output.holderContact}
              as   : "holderContact"
            }
          ]
        } as $myDocuments1
      }
    }
  }

  response = $myDocuments1
}