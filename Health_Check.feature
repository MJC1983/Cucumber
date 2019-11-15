@HealthCheck
Feature: Health Check
  The aim of this feature is to ensure that the Core service is up and running after a deployment. This feature proves that
  a client connection can be established and the status of a subscription is obtained
  Background:
    Given the "ULTRA" client is configured

    And the "Soap" web service URL is configured as:
      |https://%HostName%:%PortNumber%%endPointUrl%|

    And the required namespaces are:
      | prefix    | Namespace                                      |
      | statusres | http://statusresponse.core.schema.ultra-as.com |
      | head      | http://header.schema.ultra-as.com              |
      | afus      | http://afus.ws.schema.ultra-as.com             |
      | soapenv   | http://schemas.xmlsoap.org/soap/envelope/      |
      | acc       | http://acceptresponse.ws.schema.ultra-as.com   |

    Given the expected outputs are:
      | Node            | LocationOf                                                                                                         |
      | MessageType     | /soapenv:Envelope/soapenv:Body/afus:GetMessageResponse/statusres:Envelope/statusres:Header/head:MessageType        |
      | ServiceStatus     | /soapenv:Envelope/soapenv:Body/afus:GetMessageResponse/statusres:Envelope/statusres:Body/statusres:StatusResponse/statusres:ServiceStatus        |
      | WSRequestStatus | /soapenv:Envelope/soapenv:Body/afus:AcceptMessageResponse/acc:Envelope/acc:Body/acc:WSResponse/acc:WSRequestStatus |

    And Message type "GetMessage" is defined as:
"""
   <aaf:GetMessage xmlns:aaf="http://afus.ws.schema.ultra-as.com" xmlns:get="http://getmessage.ws.schema.ultra-as.com" xmlns:head="http://header.schema.ultra-as.com">#         <get:Envelope>
            <get:Header>
               <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
               <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
               <head:MessageType>WSRequest</head:MessageType>
               <head:SourceSystemID>Ultra</head:SourceSystemID>
               <head:DestinationSystemID>AODB</head:DestinationSystemID>
            </get:Header>
            <get:Body>
               <get:WSRequest/>
            </get:Body>
         </get:Envelope>
      </aaf:GetMessage>
"""

    And Message type "StatusRequest" is defined as:
"""
<aaf:StatusRequest xmlns:aaf="http://afus.ws.schema.ultra-as.com" xmlns:stat="http://statusrequest.core.schema.ultra-as.com" xmlns:head="http://header.schema.ultra-as.com" xsi:schemaLocation="http://statusrequest.core.schema.ultra-as.com StatusRequest.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <stat:Envelope>
            <stat:Header>
               <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
               <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
               <head:MessageType>StatusRequest</head:MessageType>
               <head:SourceSystemID>ULTRA</head:SourceSystemID>
               <head:DestinationSystemID>AODB</head:DestinationSystemID>
            </stat:Header>
            <stat:Body>
               <stat:StatusRequest/>
            </stat:Body>
         </stat:Envelope>
</aaf:StatusRequest>
"""
    And all messages are purged from the endpoint

  Scenario: Establish Service Status
  The aim of this scenario is to check that a client can connect to the service and receive
  a status response message of 'Down' when no active subscription is in place.
  Message Flow - client sends StatusRequest > Receives "Accepted"
    When the client sends a "StatusRequest" message
    And the response received is "Accepted" in the "WSRequestStatus" element
    When the client sends a "GetMessage" message
    Then the response received is "StatusResponse" in the "MessageType" element
    And the response received is "Up" in the "ServiceStatus" element

