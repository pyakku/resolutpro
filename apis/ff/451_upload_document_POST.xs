query uploadDocument verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    file? document?
    text documentName? filters=trim
    int? holderContact?
    int? holderCompany?
    timestamp? issueDate?
    timestamp? expiryDate?
    timestamp? lastTestDate?
    text issuedBy? filters=trim
    text testAuditor? filters=trim
    bool globalAck?
    int documentID?
    bool validate?
  }

  stack {
    conditional {
      if ($input.documentID == 0) {
        db.get documents {
          field_name = "documentName"
          field_value = $input.documentName
        } as $documents1
      
        storage.create_attachment {
          value = $input.document
          access = "public"
          filename = ""
        } as $file
      
        conditional {
          if ($documents1 != null) {
            db.add myDocuments {
              enforce_hidden_fields = false
              data = {
                created_at    : "now"
                company       : $input.company
                document      : $documents1.id
                globalAck     : $input.globalAck
                nameUA        : $input.documentName
                issueDate     : $input.issueDate
                expiryDate    : $input.expiryDate
                holderContact : $input.holderContact
                issuedBy      : $input.issuedBy
                lastTestDate  : $input.lastTestDate
                testAuditor   : $input.testAuditor
                active        : true
                holder_company: $input.holderCompany
                file          : $file
              }
            } as $myDocuments1
          
            var $dName {
              value = $documents1.documentName
            }
          }
        
          else {
            db.add myDocuments {
              enforce_hidden_fields = false
              data = {
                created_at    : "now"
                company       : $input.company
                globalAck     : $input.globalAck
                nameUA        : $input.documentName
                issueDate     : $input.issueDate
                expiryDate    : $input.expiryDate
                holderContact : $input.holderContact
                issuedBy      : $input.issuedBy
                lastTestDate  : $input.lastTestDate
                testAuditor   : $input.testAuditor
                active        : true
                holder_company: $input.holderCompany
                file          : $file
              }
            } as $myDocuments1
          
            var $dName {
              value = $input.documentName
            }
          }
        }
      }
    
      else {
        db.get documents {
          field_name = "id"
          field_value = $input.documentID
        } as $documents2
      
        storage.create_attachment {
          value = $input.document
          access = "public"
          filename = ""
        } as $file
      
        db.add myDocuments {
          enforce_hidden_fields = false
          data = {
            created_at             : "now"
            company                : $input.company
            document               : $input.documentID
            globalAck              : $input.globalAck
            nameUA                 : $input.documentName
            issueDate              : $input.issueDate
            expiryDate             : $input.expiryDate
            holderContact          : $input.holderContact
            issuedBy               : $input.issuedBy
            lastTestDate           : $input.lastTestDate
            testAuditor            : $input.testAuditor
            active                 : true
            holder_company         : $input.holderCompany
            archived               : ""
            myPersona              : ""
            mypersonaClassification: ""
            markedForDeletion      : ""
            file                   : $file
          }
        } as $myDocuments1
      
        var $dName {
          value = $documents2.documentName
        }
      }
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    conditional {
      if ($input.validate) {
        db.edit myDocuments {
          field_name = "id"
          field_value = $myDocuments1.id
          enforce_hidden_fields = false
          data = {validationDate: now, validated: true}
        } as $myDocuments2
      }
    }
  
    api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/upload_cert_mail_customer.php"
      method = "POST"
      params = {}
        |set:"contact":$user1.name
        |set:"c_name":$dName
        |set:"u_name":$user1.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  
    // Add Global Ack Workflow Here
    conditional {
      if ($input.globalAck) {
        function.run globalAckWorkflow {
          input = {myDocumentID: $myDocuments1.id, owner: $input.company}
        } as $func1
      }
    
      else {
        function.run globalAckWorkflowFALSE {
          input = {myDocumentID: $myDocuments1.id, owner: $input.company}
        } as $func2
      }
    }
  }

  response = $api1
}