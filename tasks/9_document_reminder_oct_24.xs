task documentReminderOct24 {
  stack {
    db.query companies {
      where = $db.companies.test == false
      return = {type: "list"}
    } as $companies
  
    !db.query companies {
      where = $db.companies.id == 25
      return = {type: "list"}
    } as $companies
  
    foreach ($companies) {
      each as $company {
        db.has notification_settings {
          field_name = "companies_id"
          field_value = $company.id
        } as $hasSettings
      
        conditional {
          if ($hasSettings) {
          }
        
          else {
            db.add notification_settings {
              enforce_hidden_fields = false
              data = {companies_id: $company.id, settings: []}
            } as $notification_settings1
          }
        }
      
        db.get notification_settings {
          field_name = "companies_id"
          field_value = $company.id
        } as $settings
      
        var.update $settings {
          value = $settings.settings
        }
      
        conditional {
          if ($settings|is_empty) {
            continue
          }
        }
      
        db.query myDocuments {
          where = $db.myDocuments.company == $company.id
          return = {type: "list"}
          addon = [
            {
              name : "documents"
              input: {documents_id: $output.document}
              as   : "document"
            }
            {
              name : "contacts"
              input: {contacts_id: $output.holderContact}
              as   : "holderContact"
            }
          ]
        } as $documents
      
        conditional {
          if ($documents|is_empty) {
          }
        
          else {
            foreach ($documents) {
              each as $document {
                var $expiryDate {
                  value = $document.expiryDate
                }
              
                var $daysToExpire {
                  value = $expiryDate
                    |format_timestamp:"U":"UTC"
                    |subtract:(now|format_timestamp:"U":"UTC")
                    |divide:86400
                    |floor
                }
              
                conditional {
                  if ($daysToExpire == 1 && ($settings|in:"1 Day")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"1 Day"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
                      headers = []
                        |push:"Content-Type: application/json"
                    } as $api1
                  
                    db.add email_log {
                      enforce_hidden_fields = false
                      data = {created_at: "now", response: $api1}
                    } as $email_log1
                  }
                }
              
                conditional {
                  if ($daysToExpire == 7 && ($settings|in:"7 Days")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"7 Days"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
                      headers = []
                        |push:"Content-Type: application/json"
                    } as $api1
                  
                    db.add email_log {
                      enforce_hidden_fields = false
                      data = {created_at: "now", response: $api1}
                    } as $email_log1
                  }
                }
              
                conditional {
                  if ($daysToExpire == 14 && ($settings|in:"14 Days")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"14 Days"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
                      headers = []
                        |push:"Content-Type: application/json"
                    } as $api1
                  
                    db.add email_log {
                      enforce_hidden_fields = false
                      data = {created_at: "now", response: $api1}
                    } as $email_log1
                  }
                }
              
                conditional {
                  if ($daysToExpire == 30 && ($settings|in:"30 Days")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"30 Days"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
                      headers = []
                        |push:"Content-Type: application/json"
                    } as $api1
                  
                    db.add email_log {
                      enforce_hidden_fields = false
                      data = {created_at: "now", response: $api1}
                    } as $email_log1
                  }
                }
              
                conditional {
                  if ($daysToExpire == 60 && ($settings|in:"60 Days")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"60 Days"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
                      headers = []
                        |push:"Content-Type: application/json"
                    } as $api1
                  
                    db.add email_log {
                      enforce_hidden_fields = false
                      data = {created_at: "now", response: $api1}
                    } as $email_log1
                  }
                }
              
                conditional {
                  if ($daysToExpire == 90 && ($settings|in:"90 Days")) {
                    var $companyName {
                      value = $company.Company_Name
                    }
                  
                    db.get subscriptions {
                      field_name = "company"
                      field_value = $company.id
                      addon = [
                        {
                          name  : "user"
                          output: ["name", "l_name", "email"]
                          input : {user_id: $output.user_id}
                        }
                      ]
                    } as $subscription
                  
                    var $companyOwnerName {
                      value = $subscription.name
                    }
                  
                    conditional {
                      if ($document.document|is_empty) {
                        var $certificateName {
                          value = $document.nameUA
                        }
                      }
                    
                      else {
                        var $certificateName {
                          value = $document.document.documentName
                        }
                      }
                    }
                  
                    var $holderName {
                      value = "empty"
                    }
                  
                    var $holderEmail {
                      value = "empty"
                    }
                  
                    conditional {
                      if ($document.holderContact|is_empty) {
                      }
                    
                      else {
                        var.update $holderName {
                          value = $document.holderContact.name
                        }
                      
                        var.update $holderEmail {
                          value = $document.holderContact.email
                        }
                      }
                    }
                  
                    var $companyEmail {
                      value = $subscription.email
                    }
                  
                    api.request {
                      url = "https://itrackersignup.p3audit.com/emailAPIs/documentNotification.php"
                      method = "POST"
                      params = {}
                        |set:"certificateName":$certificateName
                        |set:"holderName":$holderName
                        |set:"expiryDate":"90 Days"
                        |set:"companyName":$companyName
                        |set:"holderEmail":$holderEmail
                        |set:"companyEmail":$companyEmail
                        |set:"companyOwnerName":$companyOwnerName
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
            }
          }
        }
      }
    }
  }

  schedule = [{starts_on: 2024-10-10 07:32:12+0000, freq: 86400}]
}