// Add Certificates required to a company irrespective of function and country.
function default_certificates_add_on_signup {
  input {
    int company_id?
  }

  stack {
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 7
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 51
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 8
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 52
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 10
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 98
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 109
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 108
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 105
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 106
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 107
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
        validated_on           : ""
      }
    } as $required_certificates_1
  
    !db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 58
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    !db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 59
        required_for_compliance: true
        active                 : true
      }
    } as $required_certificates_1
  
    !db.add required_certificates {
      enforce_hidden_fields = false
      data = {
        companies_id           : $input.company_id
        certificates_id        : 23
        active                 : true
        required_for_compliance: true
        sla_extender           : "0"
      }
    } as $required_certificates_1
  }

  response = $required_certificates_1
}