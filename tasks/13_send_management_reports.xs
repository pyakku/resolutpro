task SendManagementReports {
  stack {
    var $today {
      value = now|format_timestamp:"d":"UTC"
    }
  
    !var $today {
      value = 15
    }
  
    conditional {
      if ($today == 30) {
        !db.query companies {
          where = $db.companies.verifier_email != null && ($db.companies.mgt_report_frequency == "monthly" || $db.companies.mgt_report_frequency == "15days") && $db.companies.verifier_email != ""
          return = {type: "list"}
        } as $companies1
      
        db.query "Management Report Settings" {
          return = {type: "list"}
        } as $Management_Report_Settings1
      
        foreach ($Management_Report_Settings1) {
          each as $item {
            function.run "Emails/send_report_email" {
              input = {
                company_id: $item.company
                to_name   : $item.name
                to_email  : $item.email
              }
            } as $func1
          }
        }
      }
    
      elseif ($today == 15) {
        db.query "Management Report Settings" {
          where = $db.Management_Report_Settings.frequency == "15days"
          return = {type: "list"}
        } as $Management_Report_Settings1
      
        foreach ($Management_Report_Settings1) {
          each as $item {
            function.run "Emails/send_report_email" {
              input = {
                company_id: $item.company
                to_name   : $item.name
                to_email  : $item.email
              }
            } as $func1
          }
        }
      }
    }
  }

  schedule = [{starts_on: 2025-09-19 15:00:40+0000, freq: 86400}]
  history = 100
}