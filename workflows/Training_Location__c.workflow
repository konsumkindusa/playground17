<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Send_to_TDS_to_False</fullName>
        <field>Send_to_TDS__c</field>
        <literalValue>0</literalValue>
        <name>Set Send to TDS to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TrainLocationOutboundMessage</fullName>
        <apiVersion>38.0</apiVersion>
        <endpointUrl>https://sf-ext-msg.mathworks.com/ProductTrainingWs/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>Source_Table__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>TrainLocationOutboundMessage</name>
        <protected>false</protected>
        <useDeadLetterQueue>true</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>TrainLocationOutboundMessageRule</fullName>
        <actions>
            <name>Set_Send_to_TDS_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TrainLocationOutboundMessage</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>WF to invoke Outbound message when an active training location is created OR a training location is updated</description>
        <formula>OR(  	AND(  		ISNEW()  		, ISPICKVAL(Status__c , &apos;Active&apos;)  		)  	, ISCHANGED(Address_Line_1__c )  	, ISCHANGED(Address_Line_2__c)  	, ISCHANGED(Address_Line_3__c)  	, ISCHANGED(Address_Line_4__c)  	, ISCHANGED(Name)  	, ISCHANGED(City__c)  	, ISCHANGED(Country__c)  	, ISCHANGED(Country_Code__c)  	, ISCHANGED(State__c)  	, ISCHANGED(State_Code__c)  	, ISCHANGED(Status__c)  	, ISCHANGED(Publish_To_Web__c)          , ISCHANGED(Postal_Code__c)         , ISCHANGED(Location_Type__c)         , Send_to_TDS__c = TRUE  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
