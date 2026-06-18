query "dashboard/stats/numbers" verb=GET {
  api_group = "resolut_apis"
  auth = "user"

  input {
    int company_id?
  }

  stack {
    db.query relationships {
      where = $db.relationships.data_owner == $input.company_id
      return = {type: "list"}
    } as $processes

    var.update $processes {
      value = $processes|unique:"PTN_no"|count
    }

    db.query products {
      where = $db.products.company == $input.company_id
      return = {type: "count"}
    } as $products

    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id
      return = {type: "count"}
    } as $certificates

    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company_id
      return = {type: "count"}
    } as $policies

    db.query audit {
      where = $db.audit.companies_id == $input.company_id
      return = {type: "count"}
    } as $audits

    db.query myPersonaShare {
      where = $db.myPersonaShare.company == $input.company_id && $db.myPersonaShare.active == true && $db.myPersonaShare.approvedByReciepent == true && $db.myPersonaShare.shareByEmail == false
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.myDocument}
          as   : "myDocument"
        }
      ]
    } as $myPersonaDocsList

    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id
      return = {type: "count"}
    } as $documents

    db.query myPersonaShare {
      where = $db.myPersonaShare.company == $input.company_id && $db.myPersonaShare.active == true && $db.myPersonaShare.approvedByReciepent == true && $db.myPersonaShare.shareByEmail == false
      return = {type: "count"}
    } as $myPersonaDocs

    var.update $documents {
      value = $documents|add:$myPersonaDocs
    }

    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id && $db.myDocuments.expiryDate < now
      return = {type: "count"}
    } as $expiredDocuments

    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id && $db.myDocuments.archived == false && $db.myDocuments.validated == true
      return = {type: "count"}
    } as $validatedDocuments

    conditional {
      if ($myPersonaDocs > 0) {
        array.filter_count ($myPersonaDocsList.myDocument) if ($this.validated && $this.archived == false) as $myPersonaValidated
        var.update $validatedDocuments {
          value = $validatedDocuments|add:$myPersonaValidated
        }
      }
    }

    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id && $db.myDocuments.rejected == true && $db.myDocuments.archived == false
      return = {type: "count"}
    } as $rejectedDocuments

    conditional {
      if ($myPersonaDocs > 0) {
        array.filter_count ($myPersonaDocsList.myDocument) if ($this.rejected && $this.archived == false) as $myPersonaRejected
        var.update $rejectedDocuments {
          value = $rejectedDocuments|add:$myPersonaRejected
        }
      }
    }

    db.query myDocuments {
      where = $db.myDocuments.company == $input.company_id && $db.myDocuments.archived == true
      return = {type: "count"}
    } as $archivedDocuments

    db.get subscriptions {
      field_name = "company"
      field_value = $input.company_id
    } as $subscriptions1

    var $users {
      value = $subscriptions1.addon_user|count|add:1
    }

    db.query contacts {
      where = $db.contacts.created_by == $input.company_id
      return = {type: "count"}
    } as $contacts
  }

  response = {
    processes         : $processes
    products          : $products
    certificates      : $certificates
    policies          : $policies
    audits            : $audits
    expiredDocuments  : $expiredDocuments
    users             : $users
    contacts          : $contacts
    documents         : $documents
    rejectedDocuments : $rejectedDocuments
    validatedDocuments: $validatedDocuments
    archivedDocuments : $archivedDocuments
  }
  guid = "W5uAHcIdrtF9EHnj7AuV6iavlk8"
}
