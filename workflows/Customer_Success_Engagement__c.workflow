<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Customer_Success_Engagement_Name</fullName>
        <field>Name</field>
        <formula>RecordType.Name + &quot; Engagement for &quot; +  Account_Name__r.Name +  &quot; &quot; +Primary_Contact__r.FirstName + &quot; &quot; + Primary_Contact__r.LastName</formula>
        <name>Set Customer Success Engagement Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Customer Success Engagement Name on create</fullName>
        <actions>
            <name>Set_Customer_Success_Engagement_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Success_Engagement__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set the name to [Record Type] Engagement for [Account Name] [Primary Contact]</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
