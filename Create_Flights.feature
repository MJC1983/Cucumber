@CreateFlights
Feature: Create Flights

  The aim of this feature is to ensure that the Core AFUS service can create Arrival and Departure flights


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

  Scenario: Create Departure

     Aim of this test is to ensure that when a Create Departure message is sent via the Ultra client, the flight is created succesfully in the AODB


    Given the expected "Departure" result set is:
      | column | value             | type     | identifier |
      | FLT    | UL001             | String   | true       |
      | SDT    | TODAY             | Date     |            |
      | STD    | TODAYT150000      | DateTime | true       |
      | FST    | J                 | String   |            |
      | REG    | 4RADA             | String   |            |
      | DES    | MAN               | String   |            |

    And all data has been truncated from the "Departure" table

    When the client sends a "CreateDeparture":
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
               <req:RequestType>Create</req:RequestType>
               <req:ReportErrors>true</req:ReportErrors>
               <req:FlightIdentification>
                  <com:FlightIdentity>UL001</com:FlightIdentity>
                  <com:FlightDirection>Departure</com:FlightDirection>
                  <com:FlightRepeatCount>0</com:FlightRepeatCount>
                  <com:ScheduledDate>TODAY</com:ScheduledDate>
                  <com:IATAFlightIdentifier>
                     <com:CarrierIATACode>UL</com:CarrierIATACode>
                     <com:FlightNumber>001</com:FlightNumber>
                  </com:IATAFlightIdentifier>
                  <com:AirportIATACode>ULT</com:AirportIATACode>
               </req:FlightIdentification>
               <req:FlightData>
                  <com:Aircraft>
                     <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                     <com:AircraftRegistration>4RADA</com:AircraftRegistration>
                     <com:AircraftSubtypeIATACode>340</com:AircraftSubtypeIATACode>
                     <com:AircraftTypeICAOCode>A340</com:AircraftTypeICAOCode>
                  </com:Aircraft>
                  <com:Flight>
                     <com:FlightServiceTypeIATACode>J</com:FlightServiceTypeIATACode>
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
    Then the flight is successfully created in the AODB

  Scenario: Create Arrival



    Given the expected "Arrival" result set is:
      | column | value             | type     | identifier |
      | FLT    | UL002             | String   | true       |
      | SDT    | TODAY             | Date     |            |
      | STA    | TODAYT150000      | DateTime | true       |
      | FST    | J                 | String   |            |
      | REG    | 4RADA             | String   |            |
      | ORG    | MAN               | String   |            |

    And all data has been truncated from the "Arrival" table

    When  the client sends a "CreateArrival":

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
               <req:RequestType>Create</req:RequestType>
               <req:ReportErrors>true</req:ReportErrors>
               <req:FlightIdentification>
                  <com:FlightIdentity>UL002</com:FlightIdentity>
                  <com:FlightDirection>Arrival</com:FlightDirection>
                  <com:FlightRepeatCount>0</com:FlightRepeatCount>
                  <com:ScheduledDate>TODAY</com:ScheduledDate>
                  <com:IATAFlightIdentifier>
                     <com:CarrierIATACode>UL</com:CarrierIATACode>
                     <com:FlightNumber>002</com:FlightNumber>
                  </com:IATAFlightIdentifier>
                  <com:AirportIATACode>ULT</com:AirportIATACode>
               </req:FlightIdentification>
               <req:FlightData>
                  <com:Aircraft>
                     <com:AircraftOwnerIATACode>UL</com:AircraftOwnerIATACode>
                     <com:AircraftRegistration>4RADA</com:AircraftRegistration>
                     <com:AircraftSubtypeIATACode>340</com:AircraftSubtypeIATACode>
                     <com:AircraftTypeICAOCode>A340</com:AircraftTypeICAOCode>
                  </com:Aircraft>
                  <com:Flight>
                     <com:FlightServiceTypeIATACode>J</com:FlightServiceTypeIATACode>
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
    Then the flight is successfully created in the AODB




