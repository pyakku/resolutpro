table audit {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int companies_id? {
      table = "companies"
    }
  
    int auditor_id? {
      table = "auditor"
    }
  
    text desc? filters=trim
    int[] secondary_auditors? {
      table = "auditor"
    }
  
    bool passed?=false
    bool failed?=false
    text comments? filters=trim
    date? due_by?
    date? completed_on?
    int audit_types_id? {
      table = "audit_types"
    }
  
    int gov_body? {
      table = "certificationBody"
    }
  
    object[] certificates? {
      schema {
        text id? filters=trim
        text comment? filters=trim
        bool validated?
      }
    }
  
    object[] policies? {
      schema {
        text id? filters=trim
        text comment? filters=trim
        bool validated?
      }
    }
  
    object[] processes? {
      schema {
        text id?
        text comment? filters=trim
        bool validated?
      }
    }
  
    object[] documents? {
      schema {
        int document? {
          table = "myDocuments"
        }
      
        text comment? filters=trim
        timestamp? viewedOn?
        bool rejected?
        bool approved?
      }
    }
  
    bool action_required?
    text action_comments? filters=trim
    text place? filters=trim
    text client_contact? filters=trim
    text client_contact_contact? filters=trim
    text client_contact_phone? filters=trim
    bool acknowledged?
    object[] appeal? {
      schema {
        date? date?
        text appeal? filters=trim
      }
    }
  
    int override? {
      table = "auditor"
    }
  
    text address1? filters=trim
    text address2? filters=trim
    text governingBody? filters=trim
    int[] sharedDocuments? {
      table = "myDocuments"
    }
  
    uuid? auditIDP3?
    object[] assessmentCheck? {
      schema {
        int question? {
          table = "assessmentsV2MyAssessments"
        }
      
        text comment? filters=trim
        timestamp? checkedOn?
        bool accept?
      }
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}