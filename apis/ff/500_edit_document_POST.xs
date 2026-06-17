query editDocument verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text documentName? filters=trim
    int? holderContact?
    int? holderCompany?
    timestamp? issueDate?
    timestamp? expiryDate?
    timestamp? lastTestDate?
    text issuedBy? filters=trim
    text testAuditor? filters=trim
    int id?
    bool globalAck?
  }

  stack {
    db.edit myDocuments {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        globalAck         : $input.globalAck
        nameUA            : $input.documentName
        issueDate         : $input.issueDate
        expiryDate        : $input.expiryDate
        validationDate    : ""
        holderContact     : $input.holderContact
        issuedBy          : $input.issuedBy
        lastTestDate      : $input.lastTestDate
        testAuditor       : $input.testAuditor
        validationComments: ""
        validatedBy       : 0
        validated         : false
        rejected          : false
        holder_company    : $input.holderCompany
      }
    } as $myDocuments1
  
    // Workflow for Global Ack
    conditional {
      if ($input.globalAck) {
        function.run globalAckWorkflow {
          input = {
            myDocumentID: $myDocuments1.id
            owner       : $myDocuments1.company
          }
        } as $func1
      }
    }
  
    function.run "Edit Document Email to P3" {
      input = {myDocumentID: $input.id}
    } as $func2
  }

  response = $myDocuments1
}