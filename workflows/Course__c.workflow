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
        <fullName>CourseOutboundMessage</fullName>
        <apiVersion>38.0</apiVersion>
        <endpointUrl>https://DONOTUSEsf-ext-msg.mathworks.com/ProductTrainingWs/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>Source_Table__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>CourseOutboundMessage</name>
        <protected>false</protected>
        <useDeadLetterQueue>true</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>CourseOutboundMessageRule</fullName>
        <actions>
            <name>Set_Send_to_TDS_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CourseOutboundMessage</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>WF to invoke Outbound message when an active course is created OR a course is updated</description>
        <formula>OR(    AND(        ISNEW()        , ISPICKVAL(Status__c , &apos;Active&apos;)        )        , ISCHANGED(Course_Code__c)        , ISCHANGED(Name)        , ISCHANGED(Status__c)        , ISCHANGED(Publish_to_Web__c)        , Send_to_TDS__c = TRUE   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
