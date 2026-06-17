function backend {
  input {
  }

  stack {
    api.request {
      url = "https://p3audit.com/itracker/add_process_notification_to_vendor.php"
      method = "POST"
      params = {}
        |set:"ptn":"123456"
        |set:"receiver_email":"pyakku@gmail.com"
        |set:"company_name":"My Company"
        |set:"receiver_name":"Receiver Name"
        |set:"function":"Processing Function"
        |set:"description":"Process Description"
        |set:"country":"Country"
        |set:"receiver_company":"Receiver Company"
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  }

  response = $api_1
}