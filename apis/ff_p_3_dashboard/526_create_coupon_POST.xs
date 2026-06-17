query createCoupon verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text code? filters=trim
    timestamp? expiry?
    text desc? filters=trim
  }

  stack {
    db.add coupons {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        code      : $input.code
        used      : false
        desc      : $input.desc
        expiresOn : $input.expiry
      }
    } as $coupons1
  }

  response = $coupons1
}