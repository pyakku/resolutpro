query get_products verb=POST {
  api_group = "products"

  input {
    text company? filters=trim
  }

  stack {
    db.query products {
      where = $db.products.company == $input.company
      sort = {products.product_name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.co}
          addon: [
            {
              name  : "certificates"
              output: [
                "id"
                "created_at"
                "Certificate_Name"
                "Certificate_Desc"
                "details"
                "q1"
                "q2"
                "q3"
                "q4"
                "q5"
                "approved"
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
              as    : "certificates_id"
            }
          ]
          as   : "co"
        }
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.coc}
          addon: [
            {
              name : "certificates"
              input: {certificates_id: $output.certificates_id}
              as   : "certificates_id"
            }
          ]
          as   : "coc"
        }
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.coa}
          addon: [
            {
              name : "certificates"
              input: {certificates_id: $output.certificates_id}
              as   : "certificates_id"
            }
          ]
          as   : "coa"
        }
        {
          name : "products"
          input: {products_id: $output.$this}
          addon: [
            {
              name : "companies_01"
              input: {companies_id: $output.company}
              as   : "company"
            }
          ]
          as   : "third_party_processors"
        }
        {
          name : "isv_category"
          input: {isv_category_id: $output.isv}
          as   : "isv"
        }
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.certificate}
          addon: [
            {
              name  : "certificates"
              output: ["Certificate_Name"]
              input : {certificates_id: $output.certificates_id}
            }
          ]
          as   : "certificates.certificate"
        }
      ]
    } as $products_1
  }

  response = $products_1
}