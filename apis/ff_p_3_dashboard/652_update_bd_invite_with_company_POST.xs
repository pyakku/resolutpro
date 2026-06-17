query updateBDInviteWithCompany verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int id?
    int company?
  }

  stack {
    db.edit business_dev_invites {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {responding_company: $input.company|to_int}
    } as $business_dev_invites1
  }

  response = {result1: $business_dev_invites1}
}