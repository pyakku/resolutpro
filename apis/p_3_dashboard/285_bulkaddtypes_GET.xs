query bulkaddtypes verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    var $var_1 {
      value = []
        |push:"Adverse Publicity Policy"
        |push:"Anti Bribery Policy"
        |push:"Anti Corruption Bribery and Fraud Policy"
        |push:"Anti-Facilitation of Tax Evasion Policy"
        |push:"Break & Lunch Policy"
        |push:"Business Continuity Plan"
        |push:"Business Management System Manual"
        |push:"Code of Conduct Policy"
        |push:"Corporate Responsibility Policy"
        |push:"Corporate Social Responsibility Policy"
        |push:"Criminal Finance Statement"
        |push:"Customer Care Policy"
        |push:"Data Protection (GDPR) Policy"
        |push:"Data Protection (POPI) Policy"
        |push:"Drugs & Alcohol Policy Statement"
        |push:"Employee Handbook"
        |push:"Environmental & Sustainability Policy"
        |push:"Environmental Operational Control Manual"
        |push:"Environmental Policy Statement"
        |push:"Equality Inclusion and Diversity Policy"
        |push:"Ethical Code of Conduct Policy"
        |push:"Ethical Policy Statement"
        |push:"Fitness for Work Policy"
        |push:"Health And Safety Policy Statement"
        |push:"Health and Safety Manual"
        |push:"Hours Worked Policy Statement"
        |push:"Information Security Policy"
        |push:"Living Wage Policy Statement"
        |push:"Lone Worker Policy"
        |push:"Modern Slavery Policy"
        |push:"Modern Slavery Policy Statement"
        |push:"Occupation Health Policy"
        |push:"Procurement Policy"
        |push:"Quality Policy Statement"
        |push:"Recruitment Selection Policy"
        |push:"Redundancy Policy"
        |push:"Right to Work in UK Policy"
        |push:"Safety, Health & Quality Policy"
        |push:"Security Policy"
        |push:"Timber Policy"
        |push:"TUPE Policy"
        |push:"Violence Policy"
        |push:"Waste Management Policy"
        |push:"Work Safe Policy"
        |push:"Working Time Policy"
    }
  
    foreach ($var_1) {
      each as $item {
        db.add policies {
          enforce_hidden_fields = false
          data = {created_at: "now", name: $item, desc: $item}
        } as $policies_1
      }
    }
  }

  response = $var_1
}