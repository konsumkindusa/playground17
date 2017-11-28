<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Prevent_Duplicate_Class</fullName>
        <description>This rule is to prevent the same class from being added more than once on a project</description>
        <field>Duplicate_Class_Association__c</field>
        <formula>CASESAFEID(Enterprise_Training_Agreement__r.Id) + CASESAFEID(Class__r.Id)</formula>
        <name>Prevent Duplicate Class</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Training Agreement Class Association</fullName>
        <actions>
            <name>Prevent_Duplicate_Class</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Class__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow is to prevent the same class from being added more than once on the same training agreement</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
