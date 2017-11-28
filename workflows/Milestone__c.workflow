<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Milestone_Completion_date_to_today</fullName>
        <description>This WFR sets the default Milestone Completion date to today</description>
        <field>Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Milestone Completion date to today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Milestone Completion date</fullName>
        <actions>
            <name>Set_Milestone_Completion_date_to_today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Milestone__c.Completion_Date__c</field>
            <operation>lessOrEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Milestone__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>This WFR sets the default Milestone Completion date to today</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
