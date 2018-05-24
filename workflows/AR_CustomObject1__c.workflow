<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Field_AR_update</fullName>
        <field>AR_Custom_Field3__c</field>
        <name>Field AR update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_a_field</fullName>
        <description>Update a field</description>
        <field>AR_Custom_Field3__c</field>
        <name>Update a field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AR-WorkFlow1</fullName>
        <active>true</active>
        <criteriaItems>
            <field>AR_CustomObject1__c.AR_CustomField1__c</field>
            <operation>equals</operation>
            <value>testworkflowfield1</value>
        </criteriaItems>
        <criteriaItems>
            <field>AR_CustomObject1__c.AR_Custom_Field3__c</field>
            <operation>equals</operation>
            <value>testworkflowfield3</value>
        </criteriaItems>
        <description>Add Comment for AR-WorkFlow1</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>AR_CustomObject1__c.LastModifiedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AR-WorkflowRule2</fullName>
        <actions>
            <name>Field_AR_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AR_CustomObject1__c.AR_CustomField1__c</field>
            <operation>equals</operation>
            <value>OpenDemo</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
