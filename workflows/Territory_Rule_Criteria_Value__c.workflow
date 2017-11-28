<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unique_Territory_value_Field_Update</fullName>
        <description>Updating a hidden text field - should be a unique value but we are not enforcing uniqueness as of 7/2016 because we know we have a lot of data to clean up before we can enforce uniqueness</description>
        <field>Unique_Territory_Value__c</field>
        <formula>IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_Sector&apos;, TEXT( Sector__c ) + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Id + Territory_Rule_Criteria__r.RecordType.DeveloperName, 
IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_City&apos;, City__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__c + Territory_Rule_Criteria__r.RecordType.DeveloperName, 
IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_Country_Code&apos;, Country_Code__c + Country_LongName__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__c + Territory_Rule_Criteria__r.RecordType.DeveloperName, 
IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_Name&apos;, Account_Name__c + Location__c + Country_LongName__c + Country_Code__c + State_Code__c + State_LongName__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__c + Territory_Rule_Criteria__r.RecordType.DeveloperName, 
IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_Postal_Code&apos;, Postal_Code_High__c + Postal_Code_Low__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__c + Territory_Rule_Criteria__r.RecordType.DeveloperName, 
IF(Territory_Rule_Criteria__r.RecordType.DeveloperName == &apos;Account_State_Code&apos;, Country_Code__c + Country_LongName__c + State_Code__c + State_LongName__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c + Territory_Rule_Criteria__r.Territory_Assignment_Rule__c + Territory_Rule_Criteria__r.RecordType.DeveloperName,&apos;&apos; 
) 
) 
) 
) 
) 
)</formula>
        <name>Unique Territory Value Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Prevent Duplicate Territory Rule Criteria value</fullName>
        <actions>
            <name>Unique_Territory_value_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Prevent duplicate rule entries for territory, rule, criteria and value</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
