@UpdateFlights
Feature: Update Flights

  The aim of this feature is to ensure that the Core AFUS service can update Arrival and Departure flights


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

  Scenario: Aircraft Update Departure

     Aim of this test is to ensure that when a Update Departure message is sent via the Ultra client, the flight is created succesfully in the AODB


    Given the expected "Departure" result set is:
      | column | value             | type     | identifier |
      | FLT    | UL501             | String   | true       |
      | SDT    | TODAY             | Date     |            |
      | STD    | TODAYT150000      | DateTime | true       |
      | CSG    |    MJC18             | String   |            |
      | NCL    |   5            | String   |            |
      | ACM   |    UL           | String   |            |
      | CAP  |     300          | String   |            |
      | AOA    |      UL           | String   |            |
  #    | ACE       | II             | String   |            |
      | EMC    |      6         | String   |            |
      | EMV    |     10.9           | String   |            |
      | MSH   |  Y           | String   |            |
      | MTC    | F             | String   |            |
      | MTW   | 37500           | String   |            |
   #   | GOA  | 0           | String   |            |
      | NTL | 1          | String   |            |
      | RFQ| 600         | String   |            |
      | TNO| 2112         | String   |            |
      | TAI| 104        | String   |            |
      | IGP| H       | String   |            |
      | WSP| F    | String   |            |
      | URG| DZNUTZ    | String   |            |

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
                  <com:ScheduledDate>TODAY</com:ScheduledDate>
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
				   <com:AircraftOperator>UL</com:AircraftOperator>
		          <com:EngineEmissionClass>6</com:EngineEmissionClass>
		          <com:EngineEmissionValue>10.9</com:EngineEmissionValue>
		      <com:MarshallerRequired>Req</com:MarshallerRequired>
		      <com:MaintenanceType>F</com:MaintenanceType>
		      <com:MaxTakeOffWeight>37500</com:MaxTakeOffWeight>
		      <com:NoOfTakeoffLandings>1</com:NoOfTakeoffLandings>
		<com:RadioFrequency>600</com:RadioFrequency>
		<com:FleetNumber>2112</com:FleetNumber>
		<com:AircraftTailNumber>104</com:AircraftTailNumber>
		<com:AircraftICAOGroupCode>H</com:AircraftICAOGroupCode>
		<com:WingSpanCode>F</com:WingSpanCode>
		<com:UnknownRegistration>DZNUTZ</com:UnknownRegistration>
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
    Then the flight is successfully updated in the AODB

