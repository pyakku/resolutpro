function "Emails/send_report_email" {
  input {
    int company_id?
    text to_name? filters=trim
    text to_email? filters=trim
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company_id
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.created_by_user}
          as    : "_user"
        }
      ]
    } as $companies1
  
    function.run "Emails/generate management report" {
      input = {company_id: $input.company_id}
    } as $func2
  
    var $Company_Name {
      value = $companies1.Company_Name
    }
  
    var $total_assessments {
      value = $func2.compliance_inspection_readiness.regulator.required|sum
    }
  
    var $valid_assessments {
      value = $func2.compliance_inspection_readiness.regulator.has|sum
    }
  
    var $invalid_assessments {
      value = $total_assessments|subtract:$valid_assessments
    }
  
    var $compliance_score {
      value = (($var.valid_assessments/$var.total_assessments)*100)|round:0
    }
  
    var $compliant {
      value = $var.compliance_score==100
    }
  
    security.jws_encode {
      headers = {}
      claims = $input.company_id
      key = $env.hash_key_for_report_url
      signature_algorithm = "HS256"
      ttl = 0
    } as $linkHash
  
    var $link {
      value = "https://app.p3audit.com/mgtReport?sessionId=%s"|sprintf:$linkHash
    }
  
    api.lambda {
      code = """
        var color = $var.compliant ? "green" : "red";
        
        var message = `<div style="font-family: Arial, sans-serif; font-size:14px; color:#000; max-width:600px; margin:auto;">
        
          <div style="text-align:center; margin-bottom:20px;">
            <img src="https://itrackersignup.p3audit.com/emailAPIs/itracker.png" alt="P3 Audit Logo" style="max-width:180px; height:auto;">
          </div>
        
          <p><strong>Hello ${$input.to_name},</strong></p>
        
          <p><strong>${$var.Company_Name}</strong> has a current compliance score of 
            <span style="color:${color}; font-weight:bold;">${$var.compliance_score}%</span> with 
            <span style="color:${color}; font-weight:bold;">${$var.invalid_assessments}</span> assessment points ${$var.compliant ? 'meeting requirements.' : 'needing urgent attention.'}
          </p>
        
          <p>For a more detailed report please click 
            <a href="${$var.link}" style="color:#008dff; text-decoration:underline;">here</a>.
          </p>
        
          <p>P3 Audit is here to assist you stay on top of regulatory compliance and third-party risk. If you have any questions or require further assistance, please feel free to contact our support team at 
            <a href="mailto:support@p3audit.com" style="color:#008dff; text-decoration:underline;">support@p3audit.com</a>.
          </p>
        
          <p>Regards,<br/>The P3 Audit Team</p>
        
          <p style="color:gray; font-size:12px; margin-top:20px;">
            Please do not reply to this email as it is from an address that is not monitored.
          </p>
        
        </div>`;
        
        return message;
        """
      timeout = 10
    } as $message
  
    function.run "Emails/send_email" {
      input = {
        to          : $input.to_email
        subject     : "P3 Audit Compliance Summary"
        message_html: $message
      }
    } as $func1
  }

  response = $message
}