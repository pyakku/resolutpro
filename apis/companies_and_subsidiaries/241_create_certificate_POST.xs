query create_certificate verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "certificates"
      override = {
        q1              : {hidden: true}
        q2              : {hidden: true}
        q3              : {hidden: true}
        q4              : {hidden: true}
        q5              : {hidden: true}
        logo            : {hidden: true}
        type            : {hidden: false}
        details         : {hidden: false}
        approved        : {hidden: true}
        created_at      : {hidden: true}
        Certificate_Desc: {hidden: false}
        Certificate_Name: {hidden: false}
      }
    }
  
    file? logo?
  }

  stack {
    storage.create_attachment {
      value = $input.logo
      access = "public"
      filename = ""
    } as $logo_image
  
    db.add certificates {
      enforce_hidden_fields = false
      data = {
        created_at      : "now"
        Certificate_Name: $input.Certificate_Name
        Certificate_Desc: $input.Certificate_Desc
        details         : $input.details
        approved        : true
        logo            : $logo_image
      }
    } as $certificates_1
  
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
      addon = [
        {
          name : "certificate_types"
          input: {certificate_types_id: $output.type}
          as   : "type"
        }
      ]
    } as $certificates_2
  }

  response = $certificates_2
}