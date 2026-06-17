query getAllProductsCompany verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query products {
      where = $db.products.company == $input.company
      sort = {products.product_name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.$this}
          addon: [
            {
              name : "documents"
              input: {documents_id: $output.document}
              as   : "document"
            }
          ]
          as   : "certificates"
        }
        {
          name : "products"
          input: {products_id: $output.$this}
          as   : "third_party_processors"
        }
        {
          name : "isv_category"
          input: {isv_category_id: $output.isv}
          as   : "isv"
        }
      ]
    } as $products1
  }

  response = $products1
}