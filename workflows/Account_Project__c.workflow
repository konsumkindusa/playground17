<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Duplicate_Account</fullName>
        <description>This rule is to prevent that the same opportunity can only be added once to the project.</description>
        <field>Duplicate_Account_Association__c</field>
        <formula>CASESAFEID(Project__r.Id) +  CASESAFEID(Account__r.Id)</formula>
        <name>Duplicate Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Primary_Flag</fullName>
        <field>is_Primary__c</field>
        <literalValue>1</literalValue>
        <name>Set Primary Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account_Project_Association</fullName>
        <actions>
            <name>Duplicate_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule is to prevent that the same Account can only be added once to the project.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Primary Account</fullName>
        <actions>
            <name>Set_Primary_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MW_Project__c.Count_Account__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Set Primary Account flag on Account Project Related record when first account added to the related list</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
