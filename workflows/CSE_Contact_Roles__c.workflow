<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_CSE_Contact_Association</fullName>
        <field>Unique_CSE_Contact_Role_Association__c</field>
        <formula>CASESAFEID(Customer_Success_Engagement__r.Id) + CASESAFEID( Contact__r.Id )</formula>
        <name>Update Unique CSE Contact Association</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CS Engagement Contact Role Association</fullName>
        <actions>
            <name>Update_Unique_CSE_Contact_Association</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CSE_Contact_Roles__c.Unique_CSE_Contact_Role_Association__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Workflow will populate the field Unique CSE Contact Role Association with concatenation of Customer Success Engagement Id and Contact Id. This is to maintain a unique value of association and prevent duplicates.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
