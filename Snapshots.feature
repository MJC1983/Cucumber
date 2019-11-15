@Snapshot
Feature: SnapshotRequests
Test
  Background:
    Given the client is configured to authenticate using:
      | username | ULTRA |
      | password | ULTRA |
    And the "Soap" web service URL is configured as:
      | https://%HostName%:%PortNumber%%endPointUrl% |
#      | https://10.172.253.62:2820/AAFDSServer |
    And the required namespaces are:
      | prefix    | Namespace                                      |
      | default   | http://www.iata.org/IATA/2007/00               |
      | statusres | http://statusresponse.core.schema.ultra-as.com |
      | head      | http://header.schema.ultra-as.com              |
      | aafds     | http://aafds.ws.schema.ultra-as.com            |
      | soapenv   | http://schemas.xmlsoap.org/soap/envelope/      |
      | acc       | http://acceptresponse.ws.schema.ultra-as.com   |

    And the expected outputs are:
      | Node                                   | LocationOf                                                                                                          |
      | MessageType                            | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/statusres:Envelope/statusres:Header/head:MessageType                                                               |
      | ServiceStatus                          | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/statusres:Envelope/statusres:Body/statusres:StatusResponse/statusres:ServiceStatus                                 |
      | StatusResponse                         | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/statusres:Envelope/statusres:Body/statusres:StatusResponse                                                         |
      | IATA_AIDX_FlightLegRS_Success_Response | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/default:IATA_AIDX_FlightLegRS/default:Success               |
      | NoData                                 | /soapenv:Envelope/soapenv:Body/aafds:GetMessageResponse/aafds:NoData                                                |
      | WSRequestStatus                        | /soapenv:Envelope/soapenv:Body/aafds:AcceptMessageResponse/acc:Envelope/acc:Body/acc:WSResponse/acc:WSRequestStatus |

    And the test data files are:
      | Message                               | File                              |
      | Status Message                        | status_request.txt                |
      | Get Message                           | GetMessage.txt                    |
      | Snapshot Start Request                | FullSnapshotRQ.txt                |
      | Snapshot Start Request for carrier BA | FullSnapshotRQ_Carrier_Filter.txt |
      | Snapshot Continue Request             | PartialSnapshotRQ.txt             |
      | Snapshot End Request                  | EndSubscriptionRQ.txt             |
      | Partial Snapshot Request              | partial_request.txt               |
      | Cancel Snapshot                       | cancel_Snapshot.txt               |

    And the system id is "ULTRA":

#    And the client is continuously receiving "StatusResponse" messages once a minute

  @full
  Scenario: Full Snapshot Test
    Given the client sends "Snapshot End Request"
    And the client waits for 2000 milliseconds
    Then the client sends "Snapshot Start Request"
    And the response received is "Accepted" in the "WSRequestStatus" element
    Then the client repeatedly sends "Get Message" every "1" second(s) until "2" "IATA_AIDX_FlightLegRS_Success_Response" message(s) are received or it takes longer than "120" seconds.

  @partial
  Scenario: Partial Snapshot Test
    Given the client sends "Snapshot End Request"
    Then the client sends partial snapshot request "Snapshot Continue Request"
    And the response received is "Accepted" in the "WSRequestStatus" element
    Then the client repeatedly sends "Get Message" every "1" second(s) until "2" "IATA_AIDX_FlightLegRS_Success_Response" message(s) are received or it takes longer than "120" seconds.

  @cancel
  Scenario: End Subscription Test
    Given the client sends "Snapshot Start Request"
    And the client waits for 10000 milliseconds
    Then the client sends "Status Message"
    And the client repeatedly sends "Get Message" every "1" second(s) until "1" "StatusResponse" message(s) are received or it takes longer than "120" seconds.
    Then the response received is "Up" in the "ServiceStatus" element
    Then the client sends "Snapshot End Request"
    And the response received is "Accepted" in the "WSRequestStatus" element
    And the client waits for 10000 milliseconds
    Then the client sends "Status Message"
    And the client repeatedly sends "Get Message" every "1" second(s) until "1" "StatusResponse" message(s) are received or it takes longer than "120" seconds.
    Then the response received is "Down" in the "ServiceStatus" element

  @filter
  Scenario: Carrier Flight Filter
    Given the client sends "Snapshot End Request"
    Then the client sends "Snapshot Start Request for carrier BA"
    And the response received is "Accepted" in the "WSRequestStatus" element
    Then the client repeatedly sends "Get Message" every "1" second(s) until "2" "IATA_AIDX_FlightLegRS_Success_Response" message(s) are received or it takes longer than "120" seconds.
