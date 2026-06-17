query acknowledge_cert_request_2 verb=POST {
  api_group = "p3dashboard"

  input {
    text request_id? filters=trim
    text cert_name? filters=trim
    text desc? filters=trim
    text details? filters=trim
    file? logo?
  }

  stack {
    conditional {
      if ($input.logo == null) {
        var $var_1 {
          value = null
        }
      }
    
      else {
        storage.create_image {
          value = $input.logo
          access = "public"
          filename = ""
        } as $var_1
      }
    }
  
    db.edit certificates {
      field_name = "id"
      field_value = $input.request_id
      enforce_hidden_fields = false
      data = {
        Certificate_Name: $input.cert_name
        Certificate_Desc: $input.desc
        details         : $input.details
        approved        : true
        logo            : $var_1
      }
    } as $certificates_2
  
    db.query certificates {
      where = $db.certificates.approved == false
      return = {type: "list"}
      output = ["id"]
    } as $certificates_1
  
    var.update $certificates_1 {
      value = $certificates_1.id
    }
  
    db.query required_certificates {
      where = $db.required_certificates.certificates_id in $certificates_1
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "companies_id"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}