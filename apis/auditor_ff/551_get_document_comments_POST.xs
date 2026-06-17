query getDocumentComments verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int myDocumentID?
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    var $documentComment {
      value = $audit1.documents
    }
  
    conditional {
      if ($documentComment|is_empty) {
        var $documentReviewDetails {
          value = []
        }
      }
    
      else {
        conditional {
          if ($documentComment.document|in:$input.myDocumentID) {
            api.lambda {
              code = """
                // Input: myDocumentID
                // Assume the documentComment list is already available in the environment
                
                const myDocumentID = $input.myDocumentID;
                
                
                // Filter the list to find the item where document matches input.myDocumentID
                const result = $var.documentComment.find(item => item.document === myDocumentID);
                
                // Return the result (or an empty object if not found)
                return result || {};
                """
              timeout = 10
            } as $documentReviewDetails
          
            conditional {
              if ($documentReviewDetails.approved) {
                var.update $documentReviewDetails {
                  value = $documentReviewDetails|set:"status":"Checked"
                }
              }
            
              else {
                var.update $documentReviewDetails {
                  value = $documentReviewDetails|set:"status":"Reject"
                }
              }
            }
          }
        
          else {
            var $documentReviewDetails {
              value = []
            }
          }
        }
      }
    }
  }

  response = $documentReviewDetails
}