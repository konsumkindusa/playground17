<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>NULL_end_Date_Customer_Signature</fullName>
        <description>NULL out the End Date so when an AS goes back into this status</description>
        <field>End_Time_in_Customer_Signature__c</field>
        <name>NULL end Date Customer Signature</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NULL_end_Date_Review_By_Legal</fullName>
        <description>NULL out the End Date so when an AS goes back into this status</description>
        <field>EndTime_in_Review_by_Lega__c</field>
        <name>NULL end Date Review By Legal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NULL_end_date_Review_by_Other_MWer_s</fullName>
        <description>NULL out the End Date so when an AS goes back into this status</description>
        <field>End_Time_in_Review_by_other_Mathworkers__c</field>
        <name>NULL end date Review by Other MWer&apos;s</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NULL_end_date_Review_by_VP_of_Marketing</fullName>
        <description>NUll out the date so when a AS goes back into the VP of Marketing Status</description>
        <field>End_Time_in_Review_by_VP_of_Marketing__c</field>
        <name>NULL end date Review by VP of Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_to_Student_Competition</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Student_Competition</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type to Student Competition</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Changed_field_update</fullName>
        <description>updates the Current Status field to now when the Status is changed</description>
        <field>Status_Updated_date__c</field>
        <formula>now()</formula>
        <name>Status Changed field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Start_Date_Review_by_Other_MWer_s</fullName>
        <field>Start_Time_in_Review_By_Other_Mathworker__c</field>
        <formula>NOW ()</formula>
        <name>Update Start Date Review by Other MWer&apos;s</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_start_date_Customer_Signature</fullName>
        <field>Start_Time_in_Customer_Signature__c</field>
        <formula>NOW ()</formula>
        <name>Update start date Customer Signature</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_end_date_Customer_Signature</fullName>
        <field>End_Time_in_Customer_Signature__c</field>
        <formula>NOW ()</formula>
        <name>update end date Customer Signature</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_end_date_Review_by_Legal</fullName>
        <field>EndTime_in_Review_by_Lega__c</field>
        <formula>NOW ()</formula>
        <name>update end date Review by Legal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_end_date_Review_by_Other_MathWork</fullName>
        <field>End_Time_in_Review_by_other_Mathworkers__c</field>
        <formula>NOW ()</formula>
        <name>update end date Review by Other MathWork</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_end_date_Review_by_VP_of_Marketin</fullName>
        <field>End_Time_in_Review_by_VP_of_Marketing__c</field>
        <formula>NOW ()</formula>
        <name>update end date Review by VP of Marketin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_stardate_Review_by_Legal</fullName>
        <field>Start_Time_in_Review_by_Legal__c</field>
        <formula>NOW ()</formula>
        <name>update stardate Review by Legal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_stardate_Review_by_VP_of_Marketin</fullName>
        <field>Start_Time_in_Review_by_VP_of_Marketing__c</field>
        <formula>NOW ()</formula>
        <name>update stardate Review by VP of Marketin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Academic Support Status is changed</fullName>
        <actions>
            <name>Status_Changed_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>workflow to capture when the status changes on an Academic Support Project</description>
        <formula>ISCHANGED( Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Student Competition Record</fullName>
        <actions>
            <name>Set_Record_Type_to_Student_Competition</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Academic_Support_Project__c.OwnerId</field>
            <operation>equals</operation>
            <value>Student Competition</value>
        </criteriaItems>
        <description>when a new Academic Support Project is created from teh student competition email adress, set the Record Type to Student Competition</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Status Changed from Customer Signature</fullName>
        <actions>
            <name>update_end_date_Customer_Signature</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>workflow to determine when the status is changed from &quot;Customer Signature&quot; to any other status</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL( PRIORVALUE(Status__c), &quot;Customer Signature&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Changed from Review by VP of Marketing</fullName>
        <actions>
            <name>update_end_date_Review_by_VP_of_Marketin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>workflow to determine when the status is changed from &quot;review by VP of Marketing&quot; to any other status</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL( PRIORVALUE(Status__c), &quot;review by VP of Marketing&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Changed from Reviewed by Other MathWorkers</fullName>
        <actions>
            <name>update_end_date_Review_by_Other_MathWork</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>workflow to determine when the status is changed from &quot;Reviewed by Other MathWorkers&quot; to any other status</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL( PRIORVALUE(Status__c), &quot;Review by Other MathWorkers&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status changed from Review By Legal</fullName>
        <actions>
            <name>update_end_date_Review_by_Legal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>workflow to determine when the status is changed from &quot;review by legal&quot; to any other status</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL( PRIORVALUE(Status__c), &quot;review by legal&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status changed to Customer Signature</fullName>
        <actions>
            <name>NULL_end_Date_Customer_Signature</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_start_date_Customer_Signature</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>capture when the status is changed to Review By Legal</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL(Status__c , &quot;Customer Signature&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status changed to Review By Legal</fullName>
        <actions>
            <name>NULL_end_Date_Review_By_Legal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_stardate_Review_by_Legal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>capture when the status is changed to Review By Legal</description>
        <formula>AND( ISCHANGED( Status__c ), ISPICKVAL(Status__c , &quot;Review by Legal&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status changed to Review By VP of Marketing</fullName>
        <actions>
            <name>NULL_end_date_Review_by_VP_of_Marketing</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_stardate_Review_by_VP_of_Marketin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>capture when the status is changed to Review By VP of Marketing</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL(Status__c , &quot;Review by VP of Marketing&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status changed to Review by Other MathWorkers</fullName>
        <actions>
            <name>NULL_end_date_Review_by_Other_MWer_s</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Start_Date_Review_by_Other_MWer_s</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>capture when the status is changed to Review by Other MathWorkers</description>
        <formula>AND(  ISCHANGED( Status__c ),  ISPICKVAL(Status__c , &quot;Review by Other MathWorkers&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
