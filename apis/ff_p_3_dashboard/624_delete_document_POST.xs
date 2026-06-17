query deleteDocument verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int myDocument?
  }

  stack {
    db.transaction {
      stack {
        db.get myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        } as $myDocuments1
      
        db.add myDocumentsDeleted {
          enforce_hidden_fields = false
          data = {
            id                     : $myDocuments1|get:"id":""
            created_at             : $myDocuments1|get:"created_at":""
            company                : $myDocuments1|get:"company":""
            document               : $myDocuments1|get:"document":""
            globalAck              : $myDocuments1|get:"globalAck":""
            nameUA                 : $myDocuments1|get:"nameUA":""
            issueDate              : $myDocuments1|get:"issueDate":""
            expiryDate             : $myDocuments1|get:"expiryDate":""
            validationDate         : $myDocuments1|get:"validationDate":""
            holderContact          : $myDocuments1|get:"holderContact":""
            issuedBy               : $myDocuments1|get:"issuedBy":""
            lastTestDate           : $myDocuments1|get:"lastTestDate":""
            testAuditor            : $myDocuments1|get:"testAuditor":""
            validationComments     : $myDocuments1|get:"validationComments":""
            validatedBy            : $myDocuments1|get:"validatedBy":""
            validated              : $myDocuments1|get:"validated":""
            rejected               : $myDocuments1|get:"rejected":""
            active                 : $myDocuments1|get:"active":""
            holder_company         : $myDocuments1|get:"holder_company":""
            archived               : $myDocuments1|get:"archived":""
            myPersona              : $myDocuments1|get:"myPersona":""
            mypersonaClassification: $myDocuments1|get:"mypersonaClassification":""
            markedForDeletion      : $myDocuments1|get:"markedForDeletion":""
            deletedOn              : now
            file                   : $myDocuments1|get:"file":""
          }
        } as $myDocumentsDeleted1
      
        db.del myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        }
      }
    }
  }

  response = $myDocuments1
}