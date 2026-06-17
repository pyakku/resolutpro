query get_certificates verb=POST {
  api_group = "certificates_new"

  input {
    text id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.id && $db.required_certificates.active == true && $db.required_certificates.document != null
      return = {type: "list"}
      addon = [
        {
          name  : "certificates"
          output: [
            "id"
            "Certificate_Name"
            "Certificate_Desc"
            "type"
            "logo.access"
            "logo.path"
            "logo.name"
            "logo.type"
            "logo.size"
            "logo.mime"
            "logo.meta"
            "logo.url"
          ]
          input : {certificates_id: $output.certificates_id}
          addon : [
            {
              name  : "certificate_types"
              output: ["id", "type"]
              input : {certificate_types_id: $output.type}
              as    : "type"
            }
          ]
          as    : "certificates_id"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.holder_company}
          as   : "holder_company"
        }
      ]
    } as $required_certificates_1
  
    var $return {
      value = []
    }
  
    foreach ($required_certificates_1) {
      each as $item {
        var $cname {
          value = $item.certificates_id.Certificate_Name
        }
      
        var $thisone {
          value = $item|set:"cert_name":$cname
        }
      
        var.update $return {
          value = $return|push:$thisone
        }
      }
    }
  }

  response = $return|sort:"cert_name":"itext":true
}