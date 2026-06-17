query replaceDocument verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    file? document?
    timestamp? issueDate?
    timestamp? expiryDate?
    timestamp? lastTestDate?
    text issuedBy? filters=trim
    text testAuditor? filters=trim
    int myDocumentOld?
  }

  stack {
    // Get Document To Replace
    db.get myDocuments {
      field_name = "id"
      field_value = $input.myDocumentOld
    } as $myDocuments2
  
    storage.create_attachment {
      value = $input.document
      access = "public"
      filename = ""
    } as $file
  
    // Create Archive
    db.add myDocuments {
      enforce_hidden_fields = false
      data = {
        created_at        : "now"
        company           : $myDocuments2.company
        document          : $myDocuments2.document
        globalAck         : $myDocuments2.globalAck
        nameUA            : $myDocuments2.nameUA
        issueDate         : $myDocuments2.issueDate
        expiryDate        : $myDocuments2.expiryDate
        validationDate    : $myDocuments2.validationDate
        holderContact     : $myDocuments2.holderContact
        issuedBy          : $myDocuments2.issuedBy
        lastTestDate      : $myDocuments2.lastTestDate
        testAuditor       : $myDocuments2.testAuditor
        validationComments: $myDocuments2.validationComments
        validatedBy       : $myDocuments2.validatedBy
        validated         : $myDocuments2.validated
        rejected          : $myDocuments2.rejected
        active            : $myDocuments2.active
        holder_company    : $myDocuments2.holder_company
        archived          : true
        file              : $myDocuments2.file
      }
    } as $myDocuments3
  
    db.edit myDocuments {
      field_name = "id"
      field_value = $myDocuments2.id
      enforce_hidden_fields = false
      data = {
        issueDate         : $input.issueDate
        expiryDate        : $input.expiryDate
        validationDate    : null
        issuedBy          : $input.issuedBy
        lastTestDate      : $input.lastTestDate
        testAuditor       : $input.testAuditor
        validationComments: ""
        validatedBy       : 0
        validated         : false
        rejected          : false
        active            : true
        archived          : false
        file              : $file
      }
    } as $myDocuments4
  
    db.get documents {
      field_name = "id"
      field_value = $myDocuments2.document
    } as $documents1
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/upload_cert_mail_customer.php"
      method = "POST"
      params = {}
        |set:"contact":$user1.name
        |set:"c_name":$documents1.documentName
        |set:"u_name":$user1.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $api1
}