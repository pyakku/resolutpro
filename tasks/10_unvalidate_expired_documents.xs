task unvalidateExpiredDocuments {
  stack {
    db.query myDocuments {
      where = $db.myDocuments.expiryDate < now && $db.myDocuments.validated == true && $db.myDocuments.noExpiry == false
      return = {type: "list"}
    } as $myDocuments1
  
    conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        foreach ($myDocuments1) {
          each as $item {
            db.edit myDocuments {
              field_name = "id"
              field_value = $item.id
              enforce_hidden_fields = false
              data = {
                validationDate    : now
                validationComments: "Document Expired"
                validated         : false
                rejected          : true
              }
            } as $myDocuments2
          }
        }
      }
    }
  }

  schedule = [{starts_on: 2024-10-14 03:29:43+0000, freq: 86400}]
}