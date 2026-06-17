query needed_certificates verb=GET {
  api_group = "Certificates"

  input {
    text function? filters=trim
    text country? filters=trim
  }

  stack {
    db.query certificates_needed {
      where = $db.certificates_needed.functions_id == $input.function && $db.certificates_needed.countries_id == $input.country
      return = {type: "list"}
      output = ["certificates_id"]
      addon = [
        {
          name  : "certificates"
          output: ["id", "Certificate_Name", "logo.url"]
          input : {certificates_id: $output.certificates_id}
          as    : "certificates_id"
        }
      ]
    } as $certificates_needed_1
  }

  response = $certificates_needed_1
}