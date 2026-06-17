query linkForReportPreview verb=POST {
  api_group = "management report"
  auth = "user"

  input {
    int company_id?
  }

  stack {
    security.jws_encode {
      headers = {}
      claims = $input.company_id
      key = $env.hash_key_for_report_url
      signature_algorithm = "HS256"
      ttl = 0
    } as $linkHash
  }

  response = {linkHash: $linkHash}
}