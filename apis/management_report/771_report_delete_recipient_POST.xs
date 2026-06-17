query "report/delete_recipient" verb=POST {
  api_group = "management report"
  auth = "user"

  input {
    int management_report_id?
  }

  stack {
    db.del "Management Report Settings" {
      field_name = "id"
      field_value = $input.management_report_id
    }
  }

  response = $Management_Report_Settings1
}