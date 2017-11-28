<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Is_Labor_Hours_After_Reviewed_Date</fullName>
        <field>Is_Hours_Since_Last_Reviewed_Date__c</field>
        <literalValue>1</literalValue>
        <name>Set Is Labor Hours After Reviewed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Created_By_on_Project</fullName>
        <field>Project_Latest_Time_Card_Created_By__c</field>
        <formula>CreatedBy.FirstName  &amp; &apos; &apos; &amp; CreatedBy.LastName</formula>
        <name>Update Last Created By on Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Project__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Created_Date_on_Project</fullName>
        <field>Project_Latest_Time_Card__c</field>
        <formula>Now()</formula>
        <name>Update Last Created Date on Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Project__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_TimeCard_Week_Ending_Date</fullName>
        <description>Calculate the weekending as the Saturday following the time card week date.
This formula is using the constant 6 for Saturday.</description>
        <field>Week_Ending__c</field>
        <formula>Week_Date__c  + ( 6 - MOD( Week_Date__c - DATE( 1900, 1, 7 ), 7 ) )</formula>
        <name>Update TimeCard Week Ending Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Time_Card_Created_By_Area</fullName>
        <field>Created_By_Area__c</field>
        <formula>TEXT(CreatedBy.Area__c)</formula>
        <name>Update Time Card Created By Area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Time_Card_Created_By_Role</fullName>
        <field>Created_by_Role_Name__c</field>
        <formula>CreatedBy.UserRole.Name</formula>
        <name>Update Time Card Created By Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Labor Hours After Reviewed Date</fullName>
        <actions>
            <name>Set_Is_Labor_Hours_After_Reviewed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Is Labor Hours on Project after Reviewed Date only</description>
        <formula>DATEVALUE(CreatedDate) &gt;Project__r.Last_Project_Review_Date__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Latest Time Card On Project</fullName>
        <actions>
            <name>Update_Last_Created_By_on_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Created_Date_on_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The workflow will set on the project the date when the last time card was entered, and the person name who entered the last time card. Fields on the projects : Project latest time Card,Project latest time Card Created By</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Time Card Created By Fields</fullName>
        <actions>
            <name>Update_Time_Card_Created_By_Area</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Time_Card_Created_By_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Time Card Created By User Role and User Area</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Time Card Week Ending Date</fullName>
        <actions>
            <name>Update_TimeCard_Week_Ending_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Only when Week Date is EDITed, update the Time Card Week Ending Date.
The New is handled already in the Visual Force Page controller.
evaluation criteria select because I only want to run when one field: Week_Date__c is changed.</description>
        <formula>AND(!ISNEW(), ISCHANGED( Week_Date__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
