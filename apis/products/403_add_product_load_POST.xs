query add_product_load verb=POST {
  api_group = "products"

  input {
    text company? filters=trim
  }

  stack {
    db.query isv_category {
      where = $db.isv_category.company == $input.company
      return = {type: "list"}
    } as $isv_category_1
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company && $db.required_certificates.document != null && $db.required_certificates.active == true
      return = {type: "list"}
      addon = [
        {
          name  : "certificates"
          output: ["Certificate_Name"]
          input : {certificates_id: $output.certificates_id}
        }
      ]
    } as $required_certificates_1
  
    db.query products {
      return = {type: "list"}
      addon = [
        {
          name : "required_certificates"
          input: {required_certificates_id: $output.certificate}
          as   : "certificates.certificate"
        }
      ]
    } as $products_1
  }

  response = {
    categories  : $isv_category_1
    certificates: $required_certificates_1
    products    : $products_1
  }
}