query "report/setFrequencyForCompany" verb=POST {
  api_group = "management report"
  auth = "user"

  input {
    int company_id?
    text name? filters=trim
    text email? filters=trim
    text frequency? filters=trim
  }

  stack {
    db.query "Management Report Settings" {
      where = $db.Management_Report_Settings.company == $input.company_id && $db.Management_Report_Settings.email == $input.email
      return = {type: "exists"}
    } as $Management_Report_Settings1
  
    conditional {
      if ($Management_Report_Settings1) {
      }
    
      else {
        db.add "Management Report Settings" {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            company   : $input.company_id
            name      : $input.name
            email     : $input.email
            frequency : $input.frequency
          }
        } as $Management_Report_Settings2
      }
    }
  }

  response = $Management_Report_Settings1
}