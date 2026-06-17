query audit_link_view_page_load verb=POST {
  api_group = "Audit_Send Link"

  input {
    text audit_id? filters=trim
  }

  stack {
    db.get share_audits {
      field_name = "controller"
      field_value = $input.audit_id
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          addon: [
            {
              name : "functions"
              input: {functions_id: $output.$this}
              as   : "functions"
            }
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "company"
        }
        {
          name : "my_policies"
          input: {my_policies_id: $output.$this}
          addon: [
            {
              name : "policies"
              input: {policies_id: $output.policies_id}
              as   : "policies_id"
            }
          ]
          as   : "policies"
        }
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.$this}
          addon: [
            {
              name : "certificates"
              input: {certificates_id: $output.certificates_id}
              addon: [
                {
                  name : "certificate_types"
                  input: {certificate_types_id: $output.type}
                  as   : "type"
                }
              ]
              as   : "certificate"
            }
            {
              name : "contacts"
              input: {contacts_id: $output.holder}
              as   : "holder"
            }
          ]
          as   : "certificates"
        }
      ]
    } as $share_audits_2
  }

  response = $share_audits_2
}