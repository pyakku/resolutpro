task notificationsToP3AdminUsers {
  stack {
    function.run P3DocumentsPendingValidationCount as $func1
    db.query p3DashboardUser {
      return = {type: "list"}
    } as $p3DashboardUser1
  
    foreach ($p3DashboardUser1) {
      each as $item {
        api.request {
          url = "https://itrackersignup.p3audit.com/emailAPIs/P3AdminDashboardValidationEmails.php"
          method = "POST"
          params = {}
            |set:"name":$item.Name
            |set:"email":$item.email
            |set:"count":$func1
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      }
    }
  }

  schedule = [{starts_on: 2025-03-31 03:30:00+0000, freq: 43200}]
}