query count_documents verb=POST {
  api_group = "ptn&doc pricing"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.document != null
      return = {type: "list"}
    } as $required_certificates_1
  
    db.query relationships {
      where = $db.relationships.data_owner == $input.company_id && $db.relationships.assigned_by == $input.company_id
      return = {type: "list"}
    } as $relationships_1
  
    db.query relationships {
      where = $db.relationships.assigned_by == $input.company_id && $db.relationships.sla != null
      return = {type: "count"}
    } as $slas
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company_id
      return = {type: "count"}
    } as $my_policies_1
  
    var $docs {
      value = $required_certificates_1
        |count
        |add:$slas
        |add:$my_policies_1
    }
  
    var $ptns {
      value = $relationships_1|count
    }
  }

  response = {docs: $docs, ptns: $ptns}
}