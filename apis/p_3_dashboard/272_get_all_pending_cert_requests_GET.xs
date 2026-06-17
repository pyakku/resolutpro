query get_all_pending_cert_requests verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query certificate_request {
      where = $db.certificate_request.accepted_certificate == 0
      sort = {certificate_request.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.requested_by_company}
        }
      ]
    } as $certificate_request_1
  }

  response = $certificate_request_1
}