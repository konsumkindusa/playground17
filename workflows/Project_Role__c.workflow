<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_Project_Contact_Role_Assoc</fullName>
        <description>Update the field with the project id and contact id concatenated value</description>
        <field>Unique_Project_Contact_Role_Association__c</field>
        <formula>CASESAFEID(Related_Project__r.Id) + CASESAFEID(Contact__r.Id)</formula>
        <name>Update Unique Project Contact Role Assoc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Contact Role Association</fullName>
        <actions>
            <name>Update_Unique_Project_Contact_Role_Assoc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Role__c.Unique_Project_Contact_Role_Association__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Workflow will populate the field Unique Project Contact Role Association with concatenation of Project Id and Contact Id. This is to maintain a unique value of association and prevent duplicates.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
