@HealthCheck
Feature: Health Check

  Background:
    Given the client is configured to authenticate using:
      | username | ULTRA |
      | password | ULTRA |

    Given the "Soap" web service URL is configured as:
      | https://%HostName%:%PortNumber%%endPointUrl% |
      #|http://10.172.253.14:2820/AAFDSServer|
    Given the required namespaces are:
      | prefix    | Namespace                                      |
      | statusres | http://statusresponse.core.schema.ultra-as.com |
      | head      | http://header.schema.ultra-as.com              |
      | soapenv   | http://schemas.xmlsoap.org/soap/envelope/      |
      | acc       | http://acceptresponse.ws.schema.ultra-as.com   |
      | aafds     | http://aafds.ws.schema.ultra-as.com            |

    Given the expected outputs are:
      | Node            | LocationOf                                                                                                          |
      | MessageType     | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/statusres:Envelope/statusres:Header/head:MessageType        |
      | WSRequestStatus | /soapenv:Envelope/soapenv:Body/aafds:AcceptMessageResponse/acc:Envelope/acc:Body/acc:WSResponse/acc:WSRequestStatus |
      | StatusResponse  | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/statusres:Envelope/statusres:Body/statusres:StatusResponse  |

    Given the test data files are:
      | Message        | File               |
      | Status Message | status_request.txt |
      | Get Message    | GetMessage.txt     |

    Given the system id is "ULTRA":

  Scenario: Health Check
    Given the client sends "Status Message"
    And the response received is "Accepted" in the "WSRequestStatus" element
    And the client repeatedly sends "Get Message" every "1" second(s) until "1" "StatusResponse" message(s) are received or it takes longer than "120" seconds.
    Then the response received is "StatusResponse" in the "MessageType" element
	

