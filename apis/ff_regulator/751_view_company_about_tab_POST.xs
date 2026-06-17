query viewCompanyAboutTab verb=POST {
  api_group = "FFRegulator"
  auth = "regulator"

  input {
    int company_id?
  }

  stack {
    db.query relationships {
      where = $db.relationships.data_owner == $input.company_id
      return = {type: "list"}
    } as $processes
  
    var.update $processes {
      value = $processes|unique:"PTN_no"|count
    }
  
    db.query products {
      where = $db.products.company == $input.company_id
      return = {type: "count"}
    } as $products
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id
      return = {type: "count"}
    } as $certificates
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company_id
      return = {type: "count"}
    } as $policies
  
    db.query audit {
      where = $db.audit.companies_id == $input.company_id
      return = {type: "count"}
    } as $audits
  
    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id
      return = {type: "count"}
    } as $documents
  
    db.get companies {
      field_name = "id"
      field_value = $input.company_id
    } as $company
  }

  response = {
    processes   : $processes
    products    : $products
    certificates: $certificates
    policies    : $policies
    audits      : $audits
    documents   : $documents
    company     : $company
  }
}