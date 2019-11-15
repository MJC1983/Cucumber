@CancelFlights
Feature: Cancel Flight Feature

  The aim of this feature is to ensure that the Core AFUS service can Cancel Arrival and Departure flights


  Background:
    Given the "ULTRA" client is configured

    And the "Soap" web service URL is configured as:
      |https://%HostName%:%PortNumber%%endPointUrl%|
    #https://10.172.253.61:8443/IBWS/AFUS/ULTRA

    And the AODB is up and ready to process messages

    And the required namespaces are:
      | prefix    | Namespace                                      |
      | statusres | http://statusresponse.core.schema.ultra-as.com |
      | head      | http://header.schema.ultra-as.com              |
      | afus      | http://afus.ws.schema.ultra-as.com             |
      | soapenv   | http://schemas.xmlsoap.org/soap/envelope/      |
      | acc       | http://acceptresponse.ws.schema.ultra-as.com   |
      | afusres   | http://response.afus.schema.ultra-as.com       |

    And the expected outputs are:
      | Node            | LocationOf                                                                                                                                  |
      | MessageType     | /soapenv:Envelope/soapenv:Body/afus:GetMessageResponse/statusres:Envelope/statusres:Header/head:MessageType                                 |
      | ServiceStatus   | /soapenv:Envelope/soapenv:Body/afus:GetMessageResponse/statusres:Envelope/statusres:Body/statusres:StatusResponse/statusres:ServiceStatus   |
      | WSRequest       | /soapenv:Envelope/soapenv:Body/afus:AcceptMessageResponse/acc:Envelope/acc:Body/acc:WSResponse/acc:WSRequestStatus                          |
      | AfusRequest     | /soapenv:Envelope/soapenv:Body/afus:GetMessageResponse/afusres:Envelope/afusres:Body/afusres:AFUSResponse/afusres:RequestStatus             |

    And the IB Web Service is online

  Scenario: Cancel Departure

  Aim of this test is to ensure that when a Cancel Departure message is sent via the Ultra client, the flight is succesfully canceled in the AODB, and when an update
    to the cancel date time is sent, the FCD element is updated correctly.


    Given the expected "Departure" result set is:
      | column | value             | type     | identifier |
      | FLT    | UL501             | String   | true       |
      | SDT    | TODAY             | Date     |            |
      | STD    | TODAYT150000      | DateTime | true       |
      | CSG    | MJC18             | String   |            |
      | NCL    | 5                 | String   |            |
      | ACM    | UL                | String   |            |
      | CAP    | 300               | String   |            |
      | CAN    | C                 | String   |            |
      | FSA    | CX                | String   |            |
      | FCD    | TODAYT093000      | DateTime |            |


    And all data has been deleted from the "Departure" table
    And a "departure" "UL501" flight is created for "TODAY"
    When the client sends a "UpdateDeparture":

      """
<AFUSRequest xsi:schemaLocation="http://request.afus.schema.ultra-as.com AFUSRequest.xsd" xmlns:com="http://common.schema.ultra-as.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:req="http://request.afus.schema.ultra-as.com" xmlns:head="http://header.schema.ultra-as.com">
      <req:Envelope>
         <req:Header>
            <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
            <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
               <head:MessageType>AFUSRequest</head:MessageType>
               <head:SourceSystemID>ULTRA</head:SourceSystemID>
               <head:DestinationSystemID>AODB</head:DestinationSystemID>
         </req:Header>
         <req:Body>
            <req:AFUSRequest>
               <req:RequestID>3</req:RequestID>
               <req:RequestType>Update</req:RequestType>
               <req:ReportErrors>true</req:ReportErrors>
               <req:FlightIdentification>
                  <com:FlightIdentity>UL501</com:FlightIdentity>
                  <com:FlightDirection>Departure</com:FlightDirection>
                  <com:FlightRepeatCount>0</com:FlightRepeatCount>
                  <com:ScheduledDate>TODAYZ</com:ScheduledDate>
                  <com:IATAFlightIdentifier>
                     <com:CarrierIATACode>UL</com:CarrierIATACode>
                     <com:FlightNumber>501</com:FlightNumber>
                  </com:IATAFlightIdentifier>
                  <com:AirportIATACode>ULT</com:AirportIATACode>
               </req:FlightIdentification>
               <req:FlightData>
                  <com:Aircraft>
                  <com:AircraftCallsign>MJC18</com:AircraftCallsign>
                  <com:AircraftNoiseClass>5</com:AircraftNoiseClass>
                  <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                  <com:AircraftPassengerCapacity>300</com:AircraftPassengerCapacity>
                </com:Aircraft>
                  <com:Flight>
                     <com:FlightCancelCode>Cancelled</com:FlightCancelCode>
                     <com:FlightStatusCode>CX</com:FlightStatusCode>
                  </com:Flight>
                   <com:OperationalTimes>
               <com:ScheduledDateTime>TODAYT15:00:00Z</com:ScheduledDateTime>
            </com:OperationalTimes>
                  <com:PortsOfCall>
                     <com:PortOfCall>
                        <com:PortOfCallIATACode>MAN</com:PortOfCallIATACode>
                     </com:PortOfCall>
                  </com:PortsOfCall>
               </req:FlightData>
            </req:AFUSRequest>
         </req:Body>
      </req:Envelope>
      </AFUSRequest>
   """

    And the Web Service accepts my request
    And the client polls the Web Service with the "AfusRequest" awaiting "Accepted" in the response
   And the client waits for 5000 milliseconds
    When the client sends a "UpdateDeparture":

"""
<AFUSRequest xsi:schemaLocation="http://request.afus.schema.ultra-as.com AFUSRequest.xsd" xmlns:com="http://common.schema.ultra-as.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:req="http://request.afus.schema.ultra-as.com" xmlns:head="http://header.schema.ultra-as.com">
      <req:Envelope>
         <req:Header>
            <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
            <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
               <head:MessageType>AFUSRequest</head:MessageType>
               <head:SourceSystemID>ULTRA</head:SourceSystemID>
               <head:DestinationSystemID>AODB</head:DestinationSystemID>
         </req:Header>
         <req:Body>
            <req:AFUSRequest>
               <req:RequestID>3</req:RequestID>
               <req:RequestType>Update</req:RequestType>
               <req:ReportErrors>true</req:ReportErrors>
               <req:FlightIdentification>
                  <com:FlightIdentity>UL501</com:FlightIdentity>
                  <com:FlightDirection>Departure</com:FlightDirection>
                  <com:FlightRepeatCount>0</com:FlightRepeatCount>
                  <com:ScheduledDate>TODAYZ</com:ScheduledDate>
                  <com:IATAFlightIdentifier>
                     <com:CarrierIATACode>UL</com:CarrierIATACode>
                     <com:FlightNumber>501</com:FlightNumber>
                  </com:IATAFlightIdentifier>
                  <com:AirportIATACode>ULT</com:AirportIATACode>
               </req:FlightIdentification>
               <req:FlightData>
                  <com:Aircraft>
                  <com:AircraftCallsign>MJC18</com:AircraftCallsign>
                  <com:AircraftNoiseClass>5</com:AircraftNoiseClass>
                  <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                  <com:AircraftPassengerCapacity>300</com:AircraftPassengerCapacity>
                </com:Aircraft>
                  <com:Flight>
                     <com:FlightCancelDate>TODAYT09:30:00Z</com:FlightCancelDate>
                  </com:Flight>
                   <com:OperationalTimes>
               <com:ScheduledDateTime>TODAYT15:00:00Z</com:ScheduledDateTime>
            </com:OperationalTimes>
                  <com:PortsOfCall>
                     <com:PortOfCall>
                        <com:PortOfCallIATACode>MAN</com:PortOfCallIATACode>
                     </com:PortOfCall>
                  </com:PortsOfCall>
               </req:FlightData>
            </req:AFUSRequest>
         </req:Body>
      </req:Envelope>
      </AFUSRequest>
"""

    And the Web Service accepts my request
    And the client polls the Web Service with the "AfusRequest" awaiting "Accepted" in the response
    And the client waits for 5000 milliseconds
    Then the flight is successfully updated in the AODB


  Scenario: Cancel Arrival

  Aim of this test is to ensure that when a Cancel Arrival message is sent via the Ultra client, the flight is succesfully canceled in the AODB, and when an update
  to the cancel date time is sent, the FCD element is updated correctly.

    Given the expected "Arrival" result set is:
      | column | value             | type     | identifier |
      | FLT    | UL101             | String   | true       |
      | SDT    | TODAY             | Date     |            |
      | STA    | TODAYT150000      | DateTime | true       |
      | CSG    | MJC18             | String   |            |
      | ACM    | UL                | String   |            |
      | CAP    | 300               | String   |            |
      | AOA    | UL                | String   |            |
      | CAN    | C                 | String   |            |
      | FSA    | CX                | String   |            |
      | FCD    | TODAYT093000      | DateTime |            |


    And all data has been deleted from the "Arrival" table
    And a "arrival" "UL101" flight is created for "TODAY"

    When  the client sends a "UpdateArrival":
      """
<AFUSRequest xsi:schemaLocation="http://request.afus.schema.ultra-as.com AFUSRequest.xsd"
    xmlns:com="http://common.schema.ultra-as.com"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:req="http://request.afus.schema.ultra-as.com"
    xmlns:head="http://header.schema.ultra-as.com">
    <req:Envelope>
        <req:Header>
            <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
            <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
            <head:MessageType>AFUSRequest</head:MessageType>
            <head:SourceSystemID>ULTRA</head:SourceSystemID>
            <head:DestinationSystemID>AODB</head:DestinationSystemID>
        </req:Header>
        <req:Body>
            <req:AFUSRequest>
                <req:RequestID>3</req:RequestID>
                <req:RequestType>Update</req:RequestType>
                <req:ReportErrors>true</req:ReportErrors>
                <req:FlightIdentification>
                    <com:FlightIdentity>UL101</com:FlightIdentity>
                    <com:FlightDirection>Arrival</com:FlightDirection>
                    <com:FlightRepeatCount>0</com:FlightRepeatCount>
                    <com:ScheduledDate>TODAYZ</com:ScheduledDate>
                    <com:IATAFlightIdentifier>
                        <com:CarrierIATACode>UL</com:CarrierIATACode>
                        <com:FlightNumber>101</com:FlightNumber>
                    </com:IATAFlightIdentifier>
                    <com:AirportIATACode>ULT</com:AirportIATACode>
                </req:FlightIdentification>
                <req:FlightData>
                    <com:Aircraft>
                        <com:AircraftCallsign>MJC18</com:AircraftCallsign>
                        <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                        <com:AircraftPassengerCapacity>300</com:AircraftPassengerCapacity>
                        <com:AircraftOperator>UL</com:AircraftOperator>
                    </com:Aircraft>
                    <com:Flight>
                        <com:FlightCancelCode>Cancelled</com:FlightCancelCode>
                        <com:FlightServiceTypeIATACode>J</com:FlightServiceTypeIATACode>
                        <com:FlightStatusCode>CX</com:FlightStatusCode>
                    </com:Flight>
                    <com:OperationalTimes>
                        <com:ScheduledDateTime>TODAYT15:00:00Z</com:ScheduledDateTime>
                    </com:OperationalTimes>
                    <com:PortsOfCall>
                        <com:PortOfCall>
                            <com:PortOfCallIATACode>MAN</com:PortOfCallIATACode>
                        </com:PortOfCall>
                    </com:PortsOfCall>
                </req:FlightData>
            </req:AFUSRequest>
        </req:Body>
    </req:Envelope>
</AFUSRequest>
"""
    And the Web Service accepts my request
    And the client polls the Web Service with the "AfusRequest" awaiting "Accepted" in the response
    And the client waits for 5000 milliseconds
    When the client sends a "UpdateArrival":

    """


<AFUSRequest xsi:schemaLocation="http://request.afus.schema.ultra-as.com AFUSRequest.xsd"
    xmlns:com="http://common.schema.ultra-as.com"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:req="http://request.afus.schema.ultra-as.com"
    xmlns:head="http://header.schema.ultra-as.com">
    <req:Envelope>
        <req:Header>
            <head:MessageSentDateTime>NOW</head:MessageSentDateTime>
            <head:MessageSequenceNumber>0</head:MessageSequenceNumber>
            <head:MessageType>AFUSRequest</head:MessageType>
            <head:SourceSystemID>ULTRA</head:SourceSystemID>
            <head:DestinationSystemID>AODB</head:DestinationSystemID>
        </req:Header>
        <req:Body>
            <req:AFUSRequest>
                <req:RequestID>3</req:RequestID>
                <req:RequestType>Update</req:RequestType>
                <req:ReportErrors>true</req:ReportErrors>
                <req:FlightIdentification>
                    <com:FlightIdentity>UL101</com:FlightIdentity>
                    <com:FlightDirection>Arrival</com:FlightDirection>
                    <com:FlightRepeatCount>0</com:FlightRepeatCount>
                    <com:ScheduledDate>TODAYZ</com:ScheduledDate>
                    <com:IATAFlightIdentifier>
                        <com:CarrierIATACode>UL</com:CarrierIATACode>
                        <com:FlightNumber>101</com:FlightNumber>
                    </com:IATAFlightIdentifier>
                    <com:AirportIATACode>ULT</com:AirportIATACode>
                </req:FlightIdentification>
                <req:FlightData>
                    <com:Aircraft>
                        <com:AircraftCallsign>MJC18</com:AircraftCallsign>
                        <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                        <com:AircraftPassengerCapacity>300</com:AircraftPassengerCapacity>
                        <com:AircraftOperator>UL</com:AircraftOperator>
                    </com:Aircraft>
                    <com:Flight>
                        <com:FlightCancelDate>TODAYT09:30:00Z</com:FlightCancelDate>
                    </com:Flight>
                    <com:OperationalTimes>
                        <com:ScheduledDateTime>TODAYT15:00:00Z</com:ScheduledDateTime>
                    </com:OperationalTimes>
                    <com:PortsOfCall>
                        <com:PortOfCall>
                            <com:PortOfCallIATACode>MAN</com:PortOfCallIATACode>
                        </com:PortOfCall>
                    </com:PortsOfCall>
                </req:FlightData>
            </req:AFUSRequest>
        </req:Body>
    </req:Envelope>
</AFUSRequest>
    """


    And the Web Service accepts my request
    And the client polls the Web Service with the "AfusRequest" awaiting "Accepted" in the response
    And the client waits for 5000 milliseconds
    Then the flight is successfully updated in the AODB
