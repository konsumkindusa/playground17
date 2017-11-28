<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>email_to_new_task_owneremail_to_new_task_owner</fullName>
        <description>Email to New Task Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Alert_Email_Templates/Task_re_assigned_to_new_Owner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Is_Requested_for_Escalation</fullName>
        <field>Is_Requested_For_Escalation__c</field>
        <literalValue>1</literalValue>
        <name>Is Requested for Escalation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SPQ_Change_Date</fullName>
        <description>Capture the date and time the Task Type was changed FROM Sales Phone Queue to any other value, including null</description>
        <field>SPQ_Change_Date__c</field>
        <formula>NOW()</formula>
        <name>SPQ Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SPQ_ChangedByUser</fullName>
        <description>First and Last Name of User who changed Type from Sales Phone Queue to another Type</description>
        <field>SPQ_ChangedByUserName__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>SPQ_ChangedByUser</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Task_Public_set_to_TRUE</fullName>
        <description>on Task, set Task Public to TRUE</description>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>Task Public set to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tasks_Set_Closed_Date</fullName>
        <field>Close_Date_Time__c</field>
        <formula>Now()</formula>
        <name>Tasks Set Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Category</fullName>
        <field>Category__c</field>
        <literalValue>Escalation – Request to Dev</literalValue>
        <name>Update Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Escalate_To_to_Null</fullName>
        <description>Update the Escalate To field to Null</description>
        <field>Escalate_To__c</field>
        <name>Update Escalate To to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SPQ_Changed</fullName>
        <actions>
            <name>SPQ_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SPQ_ChangedByUser</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>We know when Sales Phone Queue task has been changed to any other value (including no value)</description>
        <formula>AND( ISCHANGED(Type),ISPICKVAL(PRIORVALUE (Type),  &apos;Sales Phone Queue&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Task Update Closed Date</fullName>
        <actions>
            <name>Tasks_Set_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Task.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Close_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set date/time when Task isClosed and the Closed date/time is null
We have code in the TaskTriggerHandler to set the ClosedDate for Email since we discovered the Workflow did not evaluate for outgoing emails.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task Update Public to TRUE</fullName>
        <actions>
            <name>Task_Public_set_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Related_to_ObjectName__c</field>
            <operation>equals</operation>
            <value>Case</value>
        </criteriaItems>
        <description>when a Task is created, set Public to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Category for escalated emails</fullName>
        <actions>
            <name>Is_Requested_for_Escalation</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Type</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Description</field>
            <operation>contains</operation>
            <value>DEVID</value>
        </criteriaItems>
        <description>will update category on Task for escalated emails</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Escalate To when Type is not Escalation</fullName>
        <actions>
            <name>Update_Escalate_To_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Escalate To to null if the Type is not Escalation</description>
        <formula>OR(ISNEW(), ISCHANGED(Type)) &amp;&amp; (NOT ISPICKVAL(Type, &quot;Escalation&quot;)) &amp;&amp; (NOT ISPICKVAL(Escalate_To__c, &quot;&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
