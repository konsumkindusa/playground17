<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Match_Status_Change_Date</fullName>
        <description>Update the Match Status Changed Date</description>
        <field>Match_Status_Changed_Date__c</field>
        <formula>Now()</formula>
        <name>Update Match Status Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CPN Account Match Status Changed Date</fullName>
        <actions>
            <name>Update_Match_Status_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CPN_Account_Matching__c.Match_Status__c</field>
            <operation>notEqual</operation>
            <value>Proposed</value>
        </criteriaItems>
        <description>Set the date when CPN Account Match Status has been updated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
