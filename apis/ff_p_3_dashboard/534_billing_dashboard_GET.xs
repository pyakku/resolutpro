query billingDashboard verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query billing {
      return = {type: "list"}
    } as $billing1
  
    var $totalPtns {
      value = $billing1.data.ptn_price|sum
    }
  
    var $totalDocuments {
      value = $billing1.data.certificate_price|sum
    }
  
    var $totalAudits {
      value = $billing1.data.audit_price|sum
    }
  
    var $totalContacts {
      value = $billing1.data.contacts_price|sum
    }
  
    var $totalAdminUsers {
      value = $billing1.data.user_price|sum
    }
  
    var $totalDocumentShare {
      value = $billing1.data.share_price|sum
    }
  
    var $totalRevenue {
      value = $var.totalAdminUsers+$var.totalAudits+$var.totalContacts+$var.totalDocumentShare+$var.totalDocuments+$var.totalPtns
    }
  
    db.query companies {
      where = $db.companies.p3_managed == false && $db.companies.test == false && $db.companies.verified == true && $db.companies.plan != 9
      return = {type: "count"}
    } as $activeCompanies
  }

  response = {
    totalRevenue    : $totalRevenue|round:2
    activeCompanies : $activeCompanies
    projectedRevenue: 1.1
  }
}