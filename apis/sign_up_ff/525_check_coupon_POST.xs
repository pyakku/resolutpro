query checkCoupon verb=POST {
  api_group = "Sign Up FF"

  input {
    text code? filters=trim
  }

  stack {
    db.query coupons {
      where = $db.coupons.code == $input.code && $db.coupons.used == false
      return = {type: "exists"}
    } as $coupons1
  }

  response = {valid: $coupons1}
}