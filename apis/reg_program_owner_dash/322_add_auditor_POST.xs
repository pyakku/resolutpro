query add_auditor verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    dblink {
      table = "auditor"
      override = {
        city                     : {hidden: false}
        code                     : {hidden: false}
        email                    : {hidden: false}
        phone                    : {hidden: false}
        title                    : {hidden: true}
        country                  : {hidden: false}
        password                 : {hidden: true}
        last_name                : {hidden: false}
        org_email                : {hidden: false}
        org_phone                : {hidden: false}
        created_at               : {hidden: true}
        first_name               : {hidden: false}
        org_country              : {hidden: false}
        ib_membership            : {hidden: false}
        industry_body            : {hidden: true}
        governing_body           : {hidden: false}
        no_of_auditors           : {hidden: true}
        ppb_membership           : {hidden: true}
        organisation_reg         : {hidden: false}
        organisation_name        : {hidden: false}
        primary_professional_body: {hidden: true}
      }
    }
  
    text name_of_adder? filters=trim
  }

  stack {
    db.add auditor {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        first_name       : $input.first_name
        last_name        : $input.last_name
        email            : $input.email
        city             : $input.city
        country          : $input.country
        ib_membership    : $input.ib_membership
        organisation_name: $input.organisation_name
        organisation_reg : $input.organisation_reg
        phone            : $input.phone
        org_phone        : $input.org_phone
        org_email        : $input.org_email
        org_country      : $input.org_country
        code             : $input.code
        governing_body   : $input.governing_body
      }
    } as $auditor_1
  
    api.request {
      url = "https://p3audit.com/itracker/invite_auditor.php"
      method = "POST"
      params = {}
        |set:"f_name":$input.first_name
        |set:"l_name":$input.last_name
        |set:"email":$input.email
        |set:"company":$input.name_of_adder
        |set:"code":$input.code
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.query auditor {
      where = $db.auditor.governing_body overlaps $input.governing_body
      return = {type: "list"}
    } as $auditor_2
  }

  response = $auditor_2
}