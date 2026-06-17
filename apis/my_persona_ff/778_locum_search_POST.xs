query "locum/search" verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int regulator?
    text role? filters=trim
    text city? filters=trim
  }

  stack {
    var $reg {
      value = $input.regulator==0?null:$input.regulator
    }
  
    var $rol {
      value = $input.role=="Any Role"?null:$input.role
    }
  
    var $cit {
      value = $input.city=="Any City"?null:$input.city
    }
  
    db.query locum {
      where = $db.locum.regulator_id ==? $reg && $db.locum.city ==? $cit && $db.locum.role ==? $rol
      return = {type: "list"}
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.user_id}
        }
        {
          name : "regulator"
          input: {regulator_id: $output.regulator_id}
          as   : "regulator"
        }
      ]
    } as $locum1
  }

  response = $locum1
}