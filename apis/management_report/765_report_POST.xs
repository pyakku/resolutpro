query report verb=POST {
  api_group = "management report"

  input {
    text sessionId? filters=trim
  }

  stack {
    function.run "Emails/decode_token_for_report_email" {
      input = {token: $input.sessionId}
    } as $func1
  
    function.run "Emails/generate management report" {
      input = {company_id: $func1}
    } as $func2
  }

  response = $func2
}