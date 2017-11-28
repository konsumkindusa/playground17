<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_CFA_Name_on_Create</fullName>
        <field>Name</field>
        <formula>TEXT( Visit_Type__c )+ &quot; visit for &quot; +  Account__r.Name</formula>
        <name>Update CFA Name on Create</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update CFA Name on Create</fullName>
        <actions>
            <name>Update_CFA_Name_on_Create</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Facing_Activity__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>The purpose of this workflow rule is to update Customer Facing Activities Name to “[Visit Type] visit for [Account]</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
