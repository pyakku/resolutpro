query generateForms verb=POST {
  api_group = "gemini"
  auth = "user"

  input {
    file? file?
  }

  stack {
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
                |set:"text":"""
        You are an intelligent document parser.
        
        Extract all the form fields from the attached document. Each form field should be represented in the following JSON format:
        
        {
          "type": "",       // Can be "Yes/No", "Document Dropdown", "Date" or "Text"
          "title": "",      // The question or field label
          "response": ""    // Leave this empty
        }
        
        Return an array of such objects. If no form fields are found, return an empty array.
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