query dashboardNumbersMyPersona verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    db.query companies {
      where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
      return = {type: "single"}
    } as $companies1
  
    db.query myDocuments {
      where = $db.myDocuments.holderContact == $contacts1.id && $db.myDocuments.myPersona == true
      return = {type: "count"}
    } as $myDocuments1
  
    db.query myDocuments {
      where = $db.myDocuments.holderContact == $contacts1.id && $db.myDocuments.myPersona == true
      return = {type: "list"}
    } as $docList
  
    conditional {
      if ($docList|is_empty) {
        var $shareCount {
          value = 0
        }
      }
    
      else {
        var.update $docList {
          value = $docList.id|safe_array
        }
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.myDocument in $docList
          return = {type: "count"}
        } as $shareCount
      }
    }
  
    db.query myPersonaInvites {
      where = $db.myPersonaInvites.invitingUser == $auth.id
      return = {type: "count"}
    } as $myPersonaInvites1
  
    db.query share_audits {
      where = $db.share_audits.email == $user1.email
      return = {type: "list"}
    } as $share_audits1
  
    var $receivedCount {
      value = 0
    }
  
    conditional {
      if ($share_audits1|is_empty) {
      }
    
      else {
        var.update $receivedCount {
          value = $share_audits1.documents|unique:""|count
        }
      }
    }
  }

  response = {
    documents  : $myDocuments1
    shareCount : $shareCount
    inviteCount: $myPersonaInvites1
    received   : $receivedCount
  }
}