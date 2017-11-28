<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Duplicate_Project</fullName>
        <field>Duplicate_Opportunity_Association__c</field>
        <formula>CASESAFEID(Project__r.Id) +  CASESAFEID(Opportunity__r.Id)</formula>
        <name>Duplicate Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Opportunity_Project_Association</fullName>
        <actions>
            <name>Duplicate_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow is to prevent that the same opportunity can only be added once to the project.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
