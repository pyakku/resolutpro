query companies_for_auditor verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text id? filters=trim
  }

  stack {
    db.query audit {
      where = $db.audit.auditor_id == $input.id
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          addon: [
            {
              name : "countries"
              input: {countries_id: $output.country_code}
              as   : "country"
            }
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "user"
            }
          ]
          as   : "company"
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_type"
        }
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "auditor"
        }
        {
          name : "governing_body"
          input: {governing_body_id: $output.gov_body}
          as   : "governing_body"
        }
      ]
    } as $audit_1
  }

  response = $audit_1
}