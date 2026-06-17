query billilngbackup verb=POST {
  api_group = "Billing"

  input {
    text company? filters=trim
    text month? filters=trim
    text year? filters=trim
  }

  stack {
    var $first_day {
      value = ""
    }
  
    var $last_day {
      value = ""
    }
  
    var $first_day_next_month {
      value = ""
    }
  
    var $date {
      value = "01"
        |concat:($input.month|concat:$input.year:" "):"  "
        |replace:" ":""
    }
  
    var.update $date {
      value = $date|parse_timestamp:"d m Y":"UTC"
    }
  
    var.update $last_day {
      value = $date
        |transform_timestamp:"last day of this month":"UTC"
    }
  
    var.update $first_day {
      value = $date
        |transform_timestamp:"first day of this month":"UTC"
    }
  
    var.update $first_day_next_month {
      value = $date
        |transform_timestamp:"first day of next month midnight":"UTC"
    }
  
    var $certificates {
      value = 0
    }
  
    var $policies {
      value = 0
    }
  
    var $ptns {
      value = 0
    }
  
    var $admin_users {
      value = 0
    }
  
    var $audits {
      value = 0
    }
  
    var $document_share {
      value = 0
    }
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company && $db.required_certificates.document != null && $db.required_certificates.created_at < $first_day_next_month
      return = {type: "count"}
    } as $certificates
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company && $db.my_policies.document != null && $db.my_policies.created_at <= $first_day_next_month
      return = {type: "count"}
    } as $policies
  
    db.query relationships {
      where = $db.relationships.data_owner == $input.company && $db.relationships.created_at < $first_day_next_month
      return = {type: "list"}
    } as $relationships
  
    var.update $ptns {
      value = $relationships|unique:"PTN_no"|count
    }
  
    db.query subscriptions {
      where = $db.subscriptions.company == $input.company
      return = {type: "list"}
    } as $subscriptions_1
  
    var.update $admin_users {
      value = $subscriptions_1.addon_user|count
    }
  
    db.query audit {
      where = ($db.audit.created_at|timestamp_month:"UTC") == $input.month && ($db.audit.created_at|timestamp_year:"UTC") == $input.year && $db.audit.companies_id == $input.company
      return = {type: "count"}
    } as $audits
  
    db.query share_audits {
      where = ($db.share_audits.created_at|timestamp_month:"UTC") == $input.month && ($db.share_audits.created_at|timestamp_year:"UTC") == $input.year && $db.share_audits.company == $input.company
      return = {type: "count"}
    } as $document_share
  
    var $certificate_price {
      value = $certificates|multiply:0.1
    }
  
    var $policies_price {
      value = $policies|multiply:0.1
    }
  
    var $ptn_price {
      value = $ptns|multiply:0.5
    }
  
    var $user_price {
      value = $admin_users|multiply:2
    }
  
    var $audit_price {
      value = $audits|multiply:100
    }
  
    var $share_price {
      value = $document_share|multiply:5
    }
  }

  response = {
    certificates     : $certificates
    policies         : $policies
    ptns             : $ptns
    admin_users      : $admin_users
    audits           : $audits
    document_share   : $document_share
    certificate_price: $certificate_price
    policies_price   : $policies_price
    ptn_price        : $ptn_price
    user_price       : $user_price
    audit_price      : $audit_price
    share_price      : $share_price
  }
}