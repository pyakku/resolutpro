query getCouponsAll verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query coupons {
      sort = {coupons.created_at: "desc"}
      return = {type: "list"}
    } as $coupons1
  }

  response = $coupons1
}