query "locum/get_search_params" verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query regulator {
      sort = {regulator.name: "asc"}
      return = {type: "list"}
      output = ["id", "name"]
    } as $regulator1
  
    db.query locum {
      return = {type: "list"}
    } as $locum1
  
    var $roles {
      value = $locum1.role
        |sort:"":"itext":true
        |unshift:"Any Role"
    }
  
    var $city {
      value = $locum1.city
        |sort:"":"itext":true
        |unshift:"Any City"
    }
  
    var $regulator_all {
      value = {}
        |set:"id":0
        |set:"name":"Any Regulator"
    }
  }

  response = {
    regulator: $regulator1|unshift:$regulator_all
    role     : $roles
    city     : $city
  }
}