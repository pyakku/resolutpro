query "report/send_email" verb=POST {
  api_group = "management report"
  auth = "user"

  input {
    int company_id?
    text name? filters=trim
    text email? filters=trim
  }

  stack {
    function.run "Emails/send_report_email" {
      input = {
        company_id: $input.company_id
        to_name   : $input.name
        to_email  : $input.email
      }
    } as $func1
  }

  response = $func1
}