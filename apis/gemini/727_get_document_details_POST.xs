query getDocumentDetails verb=POST {
  api_group = "gemini"

  input {
    file? file?
    int company?
  }

  stack {
    !db.get myDocuments {
      field_name = "id"
      field_value = 515
    } as $myDocuments1
  
    db.query documents {
      sort = {documents.id: "asc"}
      return = {type: "list"}
      output = ["id", "documentName"]
    } as $documents1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company
      return = {type: "list"}
    } as $contact_relationship1
  
    conditional {
      if ($contact_relationship1|is_empty) {
        var $contacts1 {
          value = []
        }
      }
    
      else {
        var $contactList {
          value = $contact_relationship1.contact
        }
      
        db.query contacts {
          where = $db.contacts.id in $contactList
          return = {type: "list"}
          output = ["id", "name", "l_name"]
        } as $contacts1
      
        var.update $contacts1 {
          value = $contacts1
            |json_encode
            |replace:'"id":':""
            |replace:'"name":':""
            |replace:'"l_name":':""
        }
      }
    }
  
    var.update $documents1 {
      value = $documents1
        |json_encode
        |replace:'"id":':""
        |replace:'"documentName":':""
    }
  
    storage.read_file_resource {
      value = $input.file
    } as $file1
  
    api.request {
      url = "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=%s"|sprintf:$env.gemini_api_key
      method = "POST"
      params = {}
        |set:"contents":([]
          |push:({}
            |set:"role":"user"
            |set:"parts":([]
              |push:({}
                |set:"text":("""
        Extract these fields from the PDF or image document: Return JSON like this:{  "documentID":"","documentDesc":"", "issuer": "",  "date_of_issue": "",  "expiry_date": "",  "holder_name": "", expires:"","holderType":"" "holderID":""}If you cannot find a field return null. Date should always be in yyyy-mm-dd format. expires is always a boolean value to check if it is a expiring document. 
        holderType defaults to "Company" if it is held by a person then it will be "Employee". 
        documentDesc should be a short but precise description of the document.
        try to match the document with the list of documents below and return an the id when matched. If not matched return null. Ensure there are no mistakes.These are in a list of {id,documentName} format. %s
        try to match the holder with the list of possible holders. If not matched return null. these are in a list of {id,name,lastname} format. %s
        documentID and holderID fields are always integers. if you are matching the documentID, the description field should be the documentName for that record.
        """|sprintf:$documents1:$contacts1)
              )
              |push:({}
                |set:"inlineData":({}
                  |set:"mimeType":$file1.mime
                  |set:"data":($file1.data|base64_encode)
                )
              )
            )
          )
        )
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    !stream.from_jsonl {
      value = $api1.response.result.candidates
        |first
        |get:"content":null
        |get:"parts":null
        |first
        |get:"text":null
    } as $stream1
  }

  response = $api1.response.result.candidates
    |first
    |get:"content":null
    |get:"parts":null
    |first
    |get:"text":null
    |rtrim:" ```"
    |ltrim:"```json "
    |json_decode
}