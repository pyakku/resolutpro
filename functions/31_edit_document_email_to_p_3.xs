function "Edit Document Email to P3" {
  input {
    int myDocumentID?
  }

  stack {
    db.get myDocuments {
      field_name = "id"
      field_value = $input.myDocumentID
    } as $myDocuments1
  
    db.get companies {
      field_name = "id"
      field_value = $myDocuments1.company
    } as $companies1
  
    conditional {
      if ($myDocuments1.document == 0 || ($myDocuments1.document|is_empty)) {
        var $document {
          value = $myDocuments1.documentUA
        }
      }
    
      else {
        db.get documents {
          field_name = "id"
          field_value = $myDocuments1.document
        } as $documents1
      
        var $document {
          value = $documents1.documentName
        }
      }
    }
  
    api.request {
      url = $env.emailBase
        |concat:"upload_cert_email_p3.php":""
      method = "POST"
      params = {}
        |set:"company":$companies1.Company_Name
        |set:"c_name":$document
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $myDocuments1
}