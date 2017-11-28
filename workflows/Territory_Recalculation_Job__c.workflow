<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Send_SF_Job_Id_To_CDS</fullName>
        <apiVersion>36.0</apiVersion>
        <description>Territory Recalculation Batch Job sends where clause to CDS Account Reassignment engine</description>
        <endpointUrl>https://sf-ext-msg.mathworks.com/sfdcterrrecalcnotification/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>WHERE_Clause__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>Send SF Job Id To CDS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Send Salesforce Job Id To CDS</fullName>
        <actions>
            <name>Send_SF_Job_Id_To_CDS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Territory_Recalculation_Job__c.Status__c</field>
            <operation>equals</operation>
            <value>Submit</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
