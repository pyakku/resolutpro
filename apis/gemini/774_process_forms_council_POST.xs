query processFormsCOUNCIL verb=POST {
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
        Process the following church report data and extract the details in a json format.
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