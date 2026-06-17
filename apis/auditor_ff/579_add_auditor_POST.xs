query add_auditor verb=POST {
  api_group = "Auditor FF"
  auth = "user"

  input {
    dblink {
      table = "auditor"
      override = {
        city                     : {hidden: true}
        code                     : {hidden: true}
        email                    : {hidden: false}
        image                    : {hidden: true}
        phone                    : {hidden: true}
        title                    : {hidden: true}
        country                  : {hidden: true}
        password                 : {hidden: true}
        last_name                : {hidden: false}
        org_email                : {hidden: true}
        org_phone                : {hidden: true}
        created_at               : {hidden: true}
        first_name               : {hidden: false}
        org_country              : {hidden: true}
        ib_membership            : {hidden: true}
        industry_body            : {hidden: false}
        qualification            : {hidden: true}
        governing_body           : {hidden: true}
        no_of_auditors           : {hidden: true}
        ppb_membership           : {hidden: true}
        organisation_reg         : {hidden: true}
        organisation_name        : {hidden: true}
        primary_professional_body: {hidden: true}
      }
    }
  
    int company?
  }

  stack {
    db.has auditor {
      field_name = "email"
      field_value = $input.email
    } as $auditor_3
  
    security.random_number {
      min = 10000
      max = 8179505111
    } as $loginCode
  
    conditional {
      if ($auditor_3) {
        var $done {
          value = false
        }
      
        var $auditor {
          value = 0
        }
      }
    
      else {
        db.add auditor {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            first_name : $input.first_name
            middle_name: $input.middle_name
            last_name  : $input.last_name
            email      : $input.email
            code       : $loginCode
          }
        } as $auditor_2
      
        db.get companies {
          field_name = "id"
          field_value = $input.company
        } as $companies_1
      
        !api.request {
          url = $env.emailBase|concat:"invite_auditor.php":""
          method = "POST"
          params = {}
            |set:"f_name":$input.first_name
            |set:"l_name":$input.last_name
            |set:"email":$input.email
            |set:"company":$companies_1.Company_Name
            |set:"code":$loginCode
          headers = []
            |push:"Content-Type: application/json"
          verify_host = false
          verify_peer = false
        } as $api_1
      
        var $done {
          value = true
        }
      
        var $auditor {
          value = $auditor_2.id
        }
      }
    }
  }

  response = {done: $done, auditor: $auditor}
}