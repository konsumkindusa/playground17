<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Duplicate_Campaign</fullName>
        <description>This rule is to prevent that the same campaign can only be added once to the project.</description>
        <field>Duplicate_Campaign_Association__c</field>
        <formula>CASESAFEID(Project__r.Id) +  CASESAFEID(Campaign__r.Id)</formula>
        <name>Duplicate Campaign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Campaign_Project_Association</fullName>
        <actions>
            <name>Duplicate_Campaign</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule is to prevent that the same campaign can only be added once to the project.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
