query notifications_policies verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text rel? filters=trim
  }

  stack {
    db.query policy_requirements {
      where = $db.policy_requirements.PTN == $input.rel && $db.policy_requirements.acknowledged == false
      return = {type: "list"}
    } as $policy_requirements_1
  }

  response = $policy_requirements_1
}