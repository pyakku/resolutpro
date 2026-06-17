query get_all_certificates_reg_page verb=GET {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
      addon = [
        {
          name  : "certificate_types"
          output: ["type"]
          input : {certificate_types_id: $output.type}
          as    : "c_type"
        }
      ]
    } as $certificates1
  }

  response = $certificates1
}