query "report/getFrequencyForCompany" verb=POST {
  api_group = "management report"
  auth = "user"

  input {
    int company_id?
  }

  stack {
    db.query "Management Report Settings" {
      where = $db.Management_Report_Settings.company == $input.company_id
      return = {type: "list"}
    } as $Management_Report_Settings1
  
    foreach ($Management_Report_Settings1) {
      each as $item {
        conditional {
          if ($item.frequency == "monthly") {
            var $nextReportDate {
              value = now
                |transform_timestamp:"last day of this month":"UTC"
                |format_timestamp:"j F, Y":"UTC"
            }
          }
        
          elseif ($item.frequency == "15days") {
            var $date {
              value = now|format_timestamp:"j":"UTC"
            }
          
            conditional {
              if (($date|to_int) >= 15) {
                var $nextReportDate {
                  value = now
                    |transform_timestamp:"last day of this month":"UTC"
                    |format_timestamp:"j F, Y":"UTC"
                }
              }
            
              else {
                var $nextReportDate {
                  value = now
                    |transform_timestamp:"first day of this month midnight":"UTC"
                    |transform_timestamp:"+14 days":"UTC"
                    |format_timestamp:"j F, Y":"UTC"
                }
              }
            }
          }
        }
      
        var.update $item.nextReportDate {
          value = $nextReportDate
        }
      }
    }
  }

  response = {details: $Management_Report_Settings1}
}