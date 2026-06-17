query validateAI verb=GET {
  api_group = "gemini"

  input {
  }

  stack {
    db.get myDocuments {
      field_name = "id"
      field_value = 515
    } as $myDocuments1
  
    db.query documents {
      sort = {documents.id: "asc"}
      return = {type: "list"}
      output = ["id", "documentName"]
    } as $documents1
  
    var.update $documents1 {
      value = $documents1
        |json_encode
        |replace:'"id":':""
        |replace:'"documentName":':""
    }
  
    storage.read_file_resource {
      value = $myDocuments1.file.url
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
                |set:"text":"""
        Extract these fields from the PDF or image document: Return JSON like this:{  "documentDesc":"", "issuer": "",  "date_of_issue": "",  "expiry_date": "",  "holder_name": "", expires:"","summary":"","holderType":""}If you cannot find a field return null. Date should always be in DD-MM-YYYY format. expires is always a boolean value to check if it is a expiring document. Generate the summary field only if it is a policy document.
        holderType should be set to "Company" if it is not held by any person.
        documentDesc should be a short but precise description of the document.
        """
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