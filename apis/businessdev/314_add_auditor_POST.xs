query add_auditor verb=POST {
  api_group = "audits"

  input {
    text company? filters=trim
    dblink {
      table = "auditor"
      override = {
        city                     : {hidden: false}
        code                     : {hidden: false}
        email                    : {hidden: false}
        phone                    : {hidden: false}
        title                    : {hidden: false}
        country                  : {hidden: false}
        password                 : {hidden: true}
        last_name                : {hidden: false}
        org_email                : {hidden: false}
        org_phone                : {hidden: false}
        created_at               : {hidden: true}
        first_name               : {hidden: false}
        org_country              : {hidden: false}
        ib_membership            : {hidden: false}
        industry_body            : {hidden: false}
        governing_body           : {hidden: true}
        no_of_auditors           : {hidden: false}
        ppb_membership           : {hidden: false}
        organisation_reg         : {hidden: false}
        organisation_name        : {hidden: false}
        primary_professional_body: {hidden: false}
      }
    }
  }

  stack {
    db.has auditor {
      field_name = "email"
      field_value = $input.email
    } as $auditor_3
  
    conditional {
      if ($auditor_3) {
        var $done {
          value = ""
        }
      }
    
      else {
        db.add auditor {
          enforce_hidden_fields = false
          data = {
            created_at               : "now"
            first_name               : $input.first_name
            last_name                : $input.last_name
            email                    : $input.email
            city                     : $input.city
            country                  : $input.country
            industry_body            : $input.industry_body
            ib_membership            : $input.ib_membership
            organisation_name        : $input.organisation_name
            organisation_reg         : $input.organisation_reg
            phone                    : $input.phone
            org_phone                : $input.org_phone
            org_email                : $input.org_email
            org_country              : $input.org_country
            primary_professional_body: $input.primary_professional_body
            ppb_membership           : $input.ppb_membership
            title                    : $input.title
            no_of_auditors           : $input.no_of_auditors
          }
        } as $auditor_2
      
        db.get companies {
          field_name = "id"
          field_value = $input.company
        } as $companies_1
      
        !api.request {
          url = "https://p3audit.com/itracker/invite_auditor.php"
          method = "POST"
          params = {}
            |set:"f_name":$input.first_name
            |set:"l_name":$input.last_name
            |set:"email":$input.email
            |set:"company":$companies_1.Company_Name
            |set:"code":$input.code
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        var $done {
          value = "done"
        }
      }
    }
  
    db.query audit_types {
      return = {type: "list"}
    } as $audit_types_1
  
    db.query auditor {
      return = {type: "list"}
    } as $auditor_1
  
    db.query audit {
      where = $db.audit.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_types_id"
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "auditor_id"
        }
      ]
    } as $audit_1
  }

  response = {
    audits     : $audit_1
    audit_types: $audit_types_1
    auditors   : $auditor_1
    done       : $done
  }
}