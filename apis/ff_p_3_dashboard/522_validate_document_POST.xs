query validateDocument verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int myDocumentID?
    int document?
    text newDocumentName? filters=trim
    int newDocumentType?
    text newDocumentNewTypeName? filters=trim
    bool newDoc?
    bool newType?
    int newDocumentClassification?
    text desc? filters=trim
    text testAuditor? filters=trim
    text issuedBy? filters=trim
    timestamp? issueDate?
    timestamp? expiryDate?
    timestamp? lastTestDate?
    text validationComments? filters=trim
    bool validated?
  }

  stack {
    var $document {
      value = $input.document
    }
  
    conditional {
      if ($input.newDoc) {
        var $type {
          value = $input.newDocumentType
        }
      
        conditional {
          if ($input.newType) {
            db.add document_types {
              enforce_hidden_fields = false
              data = {created_at: "now", type: $input.newDocumentNewTypeName}
            } as $document_types1
          
            var.update $type {
              value = $document_types1.id
            }
          }
        }
      
        db.add documents {
          enforce_hidden_fields = false
          data = {
            created_at            : "now"
            documentName          : $input.newDocumentName
            documentClassification: $input.newDocumentClassification
            documentType          : $type
            approved              : true
          }
        } as $documents1
      
        var.update $document {
          value = $documents1.id
        }
      }
    }
  
    db.edit myDocuments {
      field_name = "id"
      field_value = $input.myDocumentID
      enforce_hidden_fields = false
      data = {
        document          : $document
        nameUA            : $input.desc
        issueDate         : $input.issueDate
        expiryDate        : $input.expiryDate
        validationDate    : now
        issuedBy          : $input.issuedBy
        lastTestDate      : $input.lastTestDate
        testAuditor       : $input.testAuditor
        validationComments: $input.validationComments
        validatedBy       : $auth.id
        validated         : $input.validated
        rejected          : $input.validated|not
      }
    
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.holderContact}
          as   : "holderContact"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "company"
        }
        {
          name : "documents"
          input: {documents_id: $output.document}
          as   : "document"
        }
      ]
    } as $myDocuments1
  
    conditional {
      if ($myDocuments1.document|is_empty) {
        var $docName {
          value = $myDocuments1.nameUA
        }
      }
    
      else {
        var $docName {
          value = $myDocuments1.document.documentName
        }
      }
    }
  
    // if Holder contact is present
    conditional {
      if (($myDocuments1.holderContact|is_empty) == false) {
        var $name {
          value = $myDocuments1.holderContact.name
        }
      
        var $email {
          value = $myDocuments1.holderContact.email
        }
      
        conditional {
          if ($input.validated) {
            api.request {
              url = $env.emailBase
                |concat:"validate_cert_mail.php":""
              method = "POST"
              params = {}
                |set:"contact":$name
                |set:"c_name":$docName
                |set:"u_name":$email
              headers = []
                |push:"Content-Type: application/json"
            } as $api1
          
            db.add email_log {
              enforce_hidden_fields = false
              data = {created_at: "now", response: $api1}
            } as $email_log1
          }
        
          else {
            api.request {
              url = $env.emailBase
                |concat:"validate_reject_cert_mail.php":""
              method = "POST"
              params = {}
                |set:"contact":$name
                |set:"c_name":$docName
                |set:"u_name":$email
                |set:"comment":$input.validationComments
              headers = []
                |push:"Content-Type: application/json"
            } as $api2
          
            db.add email_log {
              enforce_hidden_fields = false
              data = {created_at: "now", response: $api2}
            } as $email_log1
          }
        }
      }
    }
  
    var $name {
      value = $myDocuments1.company.created_by_user.name
    }
  
    var $email {
      value = $myDocuments1.company.created_by_user.email
    }
  
    conditional {
      if ($input.validated) {
        api.request {
          url = $env.emailBase
            |concat:"validate_cert_mail.php":""
          method = "POST"
          params = {}
            |set:"contact":$name
            |set:"c_name":$docName
            |set:"u_name":$email
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      }
    
      else {
        api.request {
          url = $env.emailBase
            |concat:"validate_reject_cert_mail.php":""
          method = "POST"
          params = {}
            |set:"contact":$name
            |set:"c_name":$docName
            |set:"u_name":$email
            |set:"comment":$input.validationComments
          headers = []
            |push:"Content-Type: application/json"
        } as $api2
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api2}
        } as $email_log1
      }
    }
  }

  response = $myDocuments1
}