query update_required_certificates verb=POST {
  api_group = "Certificates"

  input {
    int company_id?
    int[] certificates?
  }

  stack {
    foreach ($input.certificates) {
      each as $item {
        db.query required_certificates {
          where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.certificates_id == $item
          return = {type: "exists"}
        } as $exists
      
        conditional {
          if ($exists == false) {
            db.add required_certificates {
              enforce_hidden_fields = false
              data = {
                companies_id           : $input.company_id
                certificates_id        : $item
                required_for_compliance: true
              }
            } as $required_certificates_1
          }
        }
      }
    }
  }

  response = "Done"
}