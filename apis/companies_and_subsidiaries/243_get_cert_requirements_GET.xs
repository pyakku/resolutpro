query get_cert_requirements verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificates_needed {
      sort = {
        certificates_needed.countries_id: "asc"
        certificates_needed.functions_id: "desc"
      }
    
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.countries_id}
          as   : "countries_id"
        }
        {
          name : "functions"
          input: {functions_id: $output.functions_id}
          as   : "functions_id"
        }
        {
          name  : "certificates"
          output: [
            "id"
            "created_at"
            "Certificate_Name"
            "Certificate_Desc"
            "details"
            "approved"
          ]
          input : {certificates_id: $output.certificates_id}
          as    : "certificates_id"
        }
      ]
    } as $certificates_needed_1
  }

  response = $certificates_needed_1
}