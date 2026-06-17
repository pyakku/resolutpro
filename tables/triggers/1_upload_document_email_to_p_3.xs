table_trigger "Upload Document Email to P3" {
  table = "myDocuments"

  input {
    json new
    json old
    enum action {
      values = ["insert", "update", "delete", "truncate"]
    }
  
    text datasource
  }

  stack {
    conditional {
      if ($input.new.myPersona) {
      }
    
      else {
        db.get companies {
          field_name = "id"
          field_value = $input.new.company
        } as $companies1
      
        conditional {
          if ($input.new.document == 0 || ($input.new.document|is_empty)) {
            var $document {
              value = $input.new.nameUA
            }
          }
        
          else {
            db.get documents {
              field_name = "id"
              field_value = $input.new.document
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
    }
  }

  actions = {insert: true}
  history = 100
}