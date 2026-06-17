addon products {
  input {
    int products_id? {
      table = "products"
    }
  }

  stack {
    db.query products {
      where = $db.products.id == $input.products_id
      return = {type: "single"}
    }
  }
}