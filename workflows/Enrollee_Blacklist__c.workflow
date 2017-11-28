<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateBlacklistedEmailFromContact</fullName>
        <description>Update the Email field when the Contact is selected via the contact lookup on Enrollee Blacklist object.</description>
        <field>Email__c</field>
        <formula>Contact__r.Email</formula>
        <name>UpdateBlacklistedEmailFromContact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EnrolleeBlacklistContactEmailRule</fullName>
        <actions>
            <name>UpdateBlacklistedEmailFromContact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the enrollee blacklisted email from the contact chosen on the Enrollee Blacklisted record.</description>
        <formula>NOT(ISBLANK( Contact__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
