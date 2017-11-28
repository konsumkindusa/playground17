<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Remove_Agreement_Self_Enrollment_URL</fullName>
        <field>Active_Self_Enrollment_URL__c</field>
        <name>Remove Agreement Self-Enrollment URL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Enterprise_Training_Agreement__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Agreement_Self_Enrollment_Code</fullName>
        <field>Active_Self_Enrollment_URL__c</field>
        <formula>Self_Enrollment_URL__c</formula>
        <name>Update Agreement Self-Enrollment Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Enterprise_Training_Agreement__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Populate Self-Enrollment URL on Agreement</fullName>
        <actions>
            <name>Update_Agreement_Self_Enrollment_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Enrollment_Code__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Remove Self-Enrollment URL on Agreement</fullName>
        <actions>
            <name>Remove_Agreement_Self_Enrollment_URL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Status__c) &amp;&amp; TEXT(Status__c) != &quot;Active&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
