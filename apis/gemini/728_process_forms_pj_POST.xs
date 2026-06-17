query processFormsPJ verb=POST {
  api_group = "gemini"

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
        Process the following church census form data and extract the details for each member. The first entry (based on the order in the form) should be considered the head of the family (HOF). For each member, extract the following fields:
        
        - name
        - age
        - gender (MALE or FEMALE)
        - dob (Date of Birth)
        - father/mother/guardian name
        - baptised (bool, true if baptised, false otherwise)
        - confirmed (bool, true if confirmed, false otherwise)
        - education
        - headOfFamily (set to the name of the head of the family)
        
        
        Return the extracted information in JSON format
        Some names and numbers could be in Hindi/Nepali.
        convert all dates to DD/MM/YYYY format. Nepali/Hindi numbers to be converted into English.
        """
              )
              |push:({}
                |set:"inlineData":({}
                  |set:"mimeType":"image/jpeg"
                  |set:"data":($file1.data|base64_encode)
                )
              )
            )
          )
        )
      headers = []
        |push:"Content-Type: application/json"
      timeout = 50
    } as $api1
  }

  response = {
    result1: $api1.response.result.candidates|first|get:"content":null|get:"parts":null|first|get:"text":null|rtrim:" ```"|ltrim:"```json "|json_decode
    !api1  : $api1
  }
}