<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Project_Closed_Related_Opportunities_Change_Alert</fullName>
        <description>Project Closed Related Opportunities Change Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Email_Alert_Email_Templates/Project_Closed_Related_Opportunities_Change_Alert</template>
    </alerts>
    <alerts>
        <fullName>Send_Requester_Email</fullName>
        <description>Send Requester Email</description>
        <protected>false</protected>
        <recipients>
            <field>Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AE_PE_Templates/Closed_Project_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_to_AE_PE_Request_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>AE_PE_Unassigned_Requests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to AE/PE Request Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_TE_Request_Queue</fullName>
        <description>Assign the TE request to a queue after receiving request from TSR from an opportunity</description>
        <field>OwnerId</field>
        <lookupValue>TE_Unassigned_Requests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to TE Request Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_TSR_to_ProjectRule</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Project</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change TSR to Project Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Date_Project_Closed_Date</fullName>
        <description>Sets Date_Project_Closed__c to blank when the Project moves from a Closed to an Opened stage.</description>
        <field>Date_Project_Closed__c</field>
        <name>Clear Date Project Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Project_Closed_Date</fullName>
        <description>Sets Date_Project_Closed__c when the Project moves from an open to a closed stage.</description>
        <field>Date_Project_Closed__c</field>
        <formula>NOW()</formula>
        <name>Set Date Project Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Project_Closed_Only</fullName>
        <description>Set the Date Project was Closed.</description>
        <field>Date_Project_Closed__c</field>
        <formula>NOW()</formula>
        <name>Set Date Project Closed Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Df</fullName>
        <description>Set default project name if it&apos;s null</description>
        <field>Project_Name__c</field>
        <formula>IF( AND( NOT( ISBLANK( Opportunity__c ) ) ,NOT( ISBLANK(  Opportunity__r.Account.Name  ) )) ,  TEXT(Outcome__c)&amp;&apos;-&apos;&amp;Opportunity__r.Account.Name &amp;&apos;-&apos;&amp; Location_of_Request__c , TEXT(Outcome__c)  &amp; &apos;-&apos; &amp;  Account__r.Name   &amp; &apos;-&apos;&amp; Location_of_Request__c)</formula>
        <name>Set Default Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Changed_to_PE_active_field_update</fullName>
        <description>Field is updated when Project status is changed to PE Active</description>
        <field>Date_Project_Became_Active__c</field>
        <formula>NOW()</formula>
        <name>Status Changed to PE active field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AEG Assignment Rule</fullName>
        <actions>
            <name>Assign_to_AE_PE_Request_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MW_Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Request,Marketing Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>MW_Project__c.Technical_Resource_Group__c</field>
            <operation>notEqual</operation>
            <value>Technical Evangelist</value>
        </criteriaItems>
        <description>This Rule assigns Sales and marketing Technical Assistance requests to the &quot;AE_PE_Unassigned_Requests&quot; Queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Change TSR to Project</fullName>
        <actions>
            <name>Change_TSR_to_ProjectRule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow changes Project Record Type from Maketing/Sales to Project when ownership changes from Queue to a User</description>
        <formula>AND( ISCHANGED(OwnerId), LEFT(OwnerId,3) = &quot;005&quot;, LEFT (PRIORVALUE(OwnerId),3) = &quot;00G&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Date Project Closed</fullName>
        <actions>
            <name>Clear_Date_Project_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Reset the Date Project Closed field to blank if the project status has been changed from Closed or Cancelled to Open or PE: Active.</description>
        <formula>AND( OR((ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;Closed&quot;)),(ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;Cancelled&quot;))), OR((ISPICKVAL( ( Project_Status__c ) ,&quot;Open&quot;)),(ISPICKVAL( ( Project_Status__c ) ,&quot;PE: Active&quot;))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project Closed Change Made To Related Opportunities Email Alert</fullName>
        <actions>
            <name>Project_Closed_Related_Opportunities_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email to the project owner when a change has been made to the opportunities related to a closed project</description>
        <formula>AND ( ISPICKVAL(Project_Status__c ,&quot;Closed&quot; ) ,OwnerId &lt;&gt;  LastModifiedById ,ISCHANGED( Count_Opportunity__c)  , $Setup.Project_Validation_Rule_Settings__c.Prevent_Editing_Closed_Projects__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project Status Changed to PE Active</fullName>
        <actions>
            <name>Status_Changed_to_PE_active_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if Project status is changed to PE active then update the Date Project Became Active to current Date/Time</description>
        <formula>AND(ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;Open&quot;), ISPICKVAL(Project_Status__c, &quot;PE: Active&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Date Project Closed</fullName>
        <actions>
            <name>Send_Requester_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Date_Project_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Date Project Closed when Project Status is set to Closed or Cancelled only for Application Engineering or Pilot Engineering</description>
        <formula>AND(OR((ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;Open&quot;)) ,(ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;PE: Active&quot;))) ,OR( (ISPICKVAL( ( Project_Status__c ) ,&quot;Closed&quot;)) ,(ISPICKVAL( ( Project_Status__c ) ,&quot;Cancelled&quot;))) ,OR ( (ISPICKVAL( (Technical_Resource_Group__c),&quot;Application Engineering&quot; )) ,(ISPICKVAL( (Technical_Resource_Group__c),&quot;Pilot Engineering&quot; ))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Date Project Closed Only</fullName>
        <actions>
            <name>Set_Date_Project_Closed_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Date Project Closed  when Project Status is set to Closed or Cancelled only for Technical Evangelist.  Do not send email.</description>
        <formula>AND( OR((ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;Open&quot;)) ,(ISPICKVAL( PRIORVALUE( Project_Status__c ) ,&quot;PE: Active&quot;))) ,OR((ISPICKVAL( ( Project_Status__c ) ,&quot;Closed&quot;)) ,(ISPICKVAL( ( Project_Status__c ) ,&quot;Cancelled&quot;))) ,(ISPICKVAL( (Technical_Resource_Group__c) ,&quot;Technical Evangelist&quot; )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Default Project Name</fullName>
        <actions>
            <name>Set_Df</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MW_Project__c.Project_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set Default Project Name if it&apos;s not populated by user</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TE Assignment Rule</fullName>
        <actions>
            <name>Assign_to_TE_Request_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MW_Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Request,Marketing Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>MW_Project__c.Technical_Resource_Group__c</field>
            <operation>equals</operation>
            <value>Technical Evangelist</value>
        </criteriaItems>
        <description>This Rule assigns Sales and marketing Technical Assistance requests to the &quot;TE_Unassigned_Requests&quot; Queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
