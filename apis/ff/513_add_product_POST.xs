query addProduct verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text name? filters=trim
    text version? filters=trim
    text otherIdentifier? filters=trim
    text eccn? filters=trim
    text? categoryNew? filters=trim
    int? category?
    bool newCategory?
    int[]? documents?
    int[]? thirdPartyProducts?
    int company?
  }

  stack {
    conditional {
      if ($input.newCategory) {
        db.add isv_category {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            company   : $input.company
            category  : $input.categoryNew
          }
        } as $isv_category1
      
        var $categoryID {
          value = $isv_category1.id
        }
      }
    
      else {
        var $categoryID {
          value = $input.category
        }
      }
    }
  
    db.add products {
      enforce_hidden_fields = false
      data = {
        created_at            : "now"
        company               : $input.company
        isv                   : $categoryID
        product_name          : $input.name
        version               : $input.version
        other_identifiers     : $input.otherIdentifier
        certificates          : $input.documents
        ECCN                  : $input.eccn
        third_party_processors: $input.thirdPartyProducts
      }
    } as $products1
  }

  response = $products1
}