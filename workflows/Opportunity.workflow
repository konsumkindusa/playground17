<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>A_new_TAH_MAOT_Agreement_or_renewal_has_been_sold</fullName>
        <description>A new TAH MAOTS or renewal has been sold</description>
        <protected>false</protected>
        <recipients>
            <recipient>epetrell@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mabel@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mberkov@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rgraves@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rtearle@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/Sales_MAOTS_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Big_Deal_Alert</fullName>
        <description>Opportunity Big Deal Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>bmorriso@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>felixlim@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ltoolin@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mlarkin@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mmoore@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sathan@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scasalin@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Big_Deal_Alert_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Close_Date</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Change Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_System_Close_Date</fullName>
        <field>System_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>Change System Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Non_Win_Reason</fullName>
        <field>Reason__c</field>
        <name>Clear Non-Win Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Set_Previous_Stage</fullName>
        <description>Set previous Opty stage when it&apos;s changed</description>
        <field>Previous_Stage__c</field>
        <formula>TEXT( PRIORVALUE( StageName ) )</formula>
        <name>Opportunity Set Previous Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Set_Previous_Stage_Date</fullName>
        <description>Update Date/Time when Opportunity stage is changed</description>
        <field>Opportunity_Previous_Stage_Changed_Date__c</field>
        <formula>NOW()</formula>
        <name>Opportunity Set Previous Stage Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_System_Close_Date</fullName>
        <field>System_Close_Date__c</field>
        <name>Remove System Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Owner_Changed_Date_Time</fullName>
        <description>Set Date/Time when owner was changed, not when record created</description>
        <field>Owner_Change_Date_Time__c</field>
        <formula>Now()</formula>
        <name>Set Owner Changed Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Opty_Name</fullName>
        <description>Update the Opportunity Name only for Opportunities that were created from Lead Conversion.</description>
        <field>Name</field>
        <formula>LEFT( Name &amp; &apos;-&apos; &amp; Account.Name, 120)</formula>
        <name>Upd_Opty_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Time_Currency_Changed</fullName>
        <description>Update Currency Changed Date/Time</description>
        <field>Currency_Changed_Date__c</field>
        <formula>Now()</formula>
        <name>Update Date/Time Currency Changed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Close_Date</fullName>
        <description>Update Close Date to Today</description>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Update Opportunity Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Closed_Date_Changed</fullName>
        <description>Date/Time when Opportunity Closed Date changed</description>
        <field>Opportunity_Closed_Date_Changed__c</field>
        <formula>NOW()</formula>
        <name>Update Opportunity Closed Date Changed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Revenue_Amount_Changed_Date</fullName>
        <description>Date/Time when Opportunity amount was changed</description>
        <field>Last_Opportunity_Amount_Change_Date__c</field>
        <formula>Now()</formula>
        <name>Update Revenue Amount Changed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Salesforce_Opportunity_ID</fullName>
        <description>Copies the standard ID value and inserts it to the custom field Salesforce_Opportunity_ID__c on Opportunity</description>
        <field>Salesforce_Opportunity_ID__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>Update Salesforce Opportunity ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_for_Project</fullName>
        <description>Update the Stage so that it can be used to pass from the TSR to create a Project and capture the Opp Stage at the time the TSR was created</description>
        <field>Opp_Stage_for_TSR__c</field>
        <formula>TEXT( StageName )</formula>
        <name>Update Stage for Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Territory_Team_Role</fullName>
        <field>Territory_Team_Role__c</field>
        <formula>TEXT (Owner.Functional_Role__c )</formula>
        <name>Update Territory Team Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Times_Closed_Date_Changed</fullName>
        <description>Update # Times Opportunity Date was changed</description>
        <field>Times_Opportunity_Closed_Date_Changed__c</field>
        <formula>Times_Opportunity_Closed_Date_Changed__c + 1</formula>
        <name>Update # Times Closed Date Changed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Assign Territory Team Role</fullName>
        <actions>
            <name>Update_Territory_Team_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>assign territory team role based on the Opportunity owner</description>
        <formula>OR(ISCHANGED( OwnerId ),ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Big Deal Alert Over 5M</fullName>
        <actions>
            <name>Opportunity_Big_Deal_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alerts when an Opportunity Amount exceeds 5M USD.
Consulting with Salesforce suggested using Workflow instead of Big Deal Alert.  Said Big Deal Alert is only used for Orgs that do not have Workflow.</description>
        <formula>AND( ISCHANGED( USD_Amount__c ), USD_Amount__c&gt;=5000000)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Date Changed</fullName>
        <actions>
            <name>Update_Opportunity_Closed_Date_Changed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Times_Closed_Date_Changed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Date/Time when Opportunity Closed Date was changed</description>
        <formula>CloseDate  &lt;&gt;  PRIORVALUE( CloseDate )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Currency Changed Date</fullName>
        <actions>
            <name>Update_Date_Time_Currency_Changed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Last Date/Time oppty currency was updated</description>
        <formula>TEXT(CurrencyIsoCode) &lt;&gt; TEXT (PRIORVALUE(CurrencyIsoCode))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Owner Changed Date</fullName>
        <actions>
            <name>Set_Owner_Changed_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Date when opportunity owner was changed.  Updates Opportunity.Owner_Change_Date_Time__c when opportunity is created or opportunity is edited.</description>
        <formula>OwnerId &lt;&gt; PRIORVALUE( OwnerId ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Previous Stage</fullName>
        <actions>
            <name>Opportunity_Set_Previous_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opportunity_Set_Previous_Stage_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Stage_for_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture Opportunity Previous Stage when it&apos;s changed. For new Opportunity is&apos;s defaulted to the current Opty Stage</description>
        <formula>ISCHANGED(StageName)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove System Close Date</fullName>
        <actions>
            <name>Remove_System_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Remove System_Close_Date__c when the opportunity moves from a closed to an open stage.</description>
        <formula>AND(  IsClosed = FALSE,OR ((PRIORVALUE(IsClosed) = TRUE),ISNEW())  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Amount Changed Date</fullName>
        <actions>
            <name>Update_Revenue_Amount_Changed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set field to now when Opty Revenue amount has been changed</description>
        <formula>Amount &lt;&gt; PRIORVALUE( Amount )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Close Date</fullName>
        <actions>
            <name>Change_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WFR Logic : If moving to a Closed state and if CloseDate &lt; TODAY -14 THEN SET CloseDate = TODAY</description>
        <formula>AND(     CloseDate &lt; (TODAY() - 14)     ,PRIORVALUE(IsClosed) = FALSE     ,IsClosed = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set System Close Date</fullName>
        <actions>
            <name>Change_System_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets System_Close_Date__c when the opportunity moves from an open to a closed stage.</description>
        <formula>AND( IsClosed = TRUE  ,OR ((PRIORVALUE(IsClosed) = FALSE),ISNEW()) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Training MAOTS Notification</fullName>
        <actions>
            <name>A_new_TAH_MAOT_Agreement_or_renewal_has_been_sold</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Provide_agreement_information</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Key_Opportunity__c</field>
            <operation>equals</operation>
            <value>TAH - (Including MAOTS),TAH - (MAOTS Only)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Win</value>
        </criteriaItems>
        <description>This rule provides a notification to the Sales Rep as well as the Training Ops team that a MAOT training opportunity has been sold.  This will allow the training ops team to get started on creating the Enterprise Agreement and remind the rep for SP</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Close Date to Today for a Non-Win Opp</fullName>
        <actions>
            <name>Update_Opportunity_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Close Date to today&apos;s date when an Opp is changes to Non - Win</description>
        <formula>ISCHANGED( StageName ) &amp;&amp;  ISPICKVAL (StageName, &quot;Non-Win&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Non-Win Reason</fullName>
        <actions>
            <name>Clear_Non_Win_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear Non-Win Reason when stage is changed to &quot;Win&quot;</description>
        <formula>AND(   ISCHANGED( StageName ),   ISPICKVAL(StageName, &apos;Win&apos;),   NOT (ISBLANK(TEXT( Reason__c ))),   LastModifiedBy.Id = &quot;005i00000014J7w&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Salesforce  Opportunity Id</fullName>
        <actions>
            <name>Update_Salesforce_Opportunity_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Fires on create and executes a field update to allow the Opportunity to be searchable by Salesforce record Id</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Stage for TSR on Opp Create</fullName>
        <actions>
            <name>Update_Stage_for_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update_OpportunityName</fullName>
        <actions>
            <name>Upd_Opty_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Salesforce_Lead_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the Opportunity is created from Lead Conversion, update the Opportunity Name to be a concatenation of the Opportunity Account Name and the Opportunity Primary Contact Name.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>create task when opportunity is created</fullName>
        <actions>
            <name>NewTaskATOpportunity</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Salesforce_Lead_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>this will create a task if opportunity when ever an opportunity is created if opportunity created is not from converted lead</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>NewTaskATOpportunity</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Next_Activity_Due_Date__c</offsetFromField>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New Opportunity</subject>
    </tasks>
    <tasks>
        <fullName>Provide_agreement_information</fullName>
        <assignedToType>owner</assignedToType>
        <description>Additional information and action is required to accurately set-up the registration and enrollment page for your recent MAOTS

https://sharepoint.mathworks.com/salesservice/training/TrainingInside/Operations/Lists/TAHTrainingRequestTracker/AllItems.aspx</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Action Required - Complete the MAOTS Request Form</subject>
    </tasks>
</Workflow>
