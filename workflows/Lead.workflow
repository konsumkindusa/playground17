<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Lead_Hand_Raiser_Change_Alert</fullName>
        <ccEmails>aboerman@mathworks.com</ccEmails>
        <description>Lead Hand Raiser Change Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Email_Alert_Email_Templates/Lead_Hand_Raiser_Change_Alert</template>
    </alerts>
    <alerts>
        <fullName>Lead_Unassigned_Queue</fullName>
        <description>Not to Deploy Lead Unassigned Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>faina@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>fgorelik@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sample_Email_Templates/LeadsNewassignmentnotificationSAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Country_State_field</fullName>
        <field>Country_State_Code__c</field>
        <formula>IF(
	AND(CONTAINS($Setup.Countries_Requiring_States__c.Countries_Requires_States__c,TEXT(CountryCode)),ISBLANK(TEXT(StateCode))),
	Country_State_Code__c,
	IF(
	OR(ISPICKVAL(CountryCode ,&apos;US&apos;),ISPICKVAL(CountryCode ,&apos;CA&apos;)),
		TEXT(StateCode) ,
		IF(
			AND(ISBLANK(TEXT(StateCode)),ISBLANK(TEXT(CountryCode))),
				Country_State_Code__c,
				IF(
					AND(ISBLANK(TEXT(StateCode)),NOT(ISBLANK(TEXT(CountryCode)))),
					&apos;&apos;,
					TEXT(CountryCode)&amp;&apos;-&apos;&amp; TEXT(StateCode)
				)
		)
	)
)</formula>
        <name>Country State field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Completed_Date</fullName>
        <description>Blank out the Lead Completed Date when the Lead is Reopened</description>
        <field>Completed_Date__c</field>
        <name>Lead Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Outcome</fullName>
        <description>Blank out Lead Outcome when Lead is Reopened</description>
        <field>Outcome__c</field>
        <name>Lead Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Completed_Date</fullName>
        <description>Set the date when Lead was converted and status set to Closed *</description>
        <field>Completed_Date__c</field>
        <formula>Now()</formula>
        <name>Set Lead Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_First_Assigned_Date</fullName>
        <description>Date when lead was first assigned to the owner , not queue</description>
        <field>First_Assignment_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Lead First Assigned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Existing_Opp_Outcome</fullName>
        <description>Update Outcome to Existing Opportunity on Converted Lead when Existing Opportunity Id selected</description>
        <field>Outcome__c</field>
        <literalValue>Existing Opportunity</literalValue>
        <name>Update Existing Opp Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Assigned_Date</fullName>
        <description>Set Last Assigned date at the time when lead assigned to the person to the First Assigned Date</description>
        <field>Last_Assignment_Date__c</field>
        <formula>Now()</formula>
        <name>Update Last Assigned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Attempt_Date</fullName>
        <description>Sets last attempt date on lead when the total outbound attempt count changes and the total outbound attempt date &gt;= 1</description>
        <field>Last_Attempt_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Last Attempt Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_First_Attempt_Date</fullName>
        <field>First_Attempt_Date__c</field>
        <formula>Now()</formula>
        <name>Update Lead First Attempt Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Last_Assigned_Date</fullName>
        <field>Last_Assignment_Date__c</field>
        <formula>Now()</formula>
        <name>Update Lead Last Assigned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Last_Attempt_Date</fullName>
        <description>Lead last attempt date, by default  , when attempt =1, set to First Attempt Date</description>
        <field>Last_Attempt_Date__c</field>
        <formula>Now()</formula>
        <name>Update Lead Last Attempt Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Prior_Owner</fullName>
        <description>Update Prior owner of the lead</description>
        <field>Prior_Own__c</field>
        <formula>CASESAFEID(PRIORVALUE(OwnerId))</formula>
        <name>Update Lead Prior Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status</fullName>
        <description>update lead status to &apos;closed- Unconverted&apos; when the outcome is set on the Lead</description>
        <field>Status</field>
        <literalValue>Closed - Unconverted</literalValue>
        <name>Update Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_field</fullName>
        <field>Office__c</field>
        <formula>Country</formula>
        <name>Update Office field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Outcome</fullName>
        <description>Update Outcome value to &quot;CONVERTED&quot;.</description>
        <field>Outcome__c</field>
        <literalValue>CONVERTED</literalValue>
        <name>Update Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead Completed Date</fullName>
        <actions>
            <name>Set_Lead_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Runs when Lead status contains Closed</description>
        <formula>ISCHANGED(Status)  &amp;&amp;  (ISPICKVAL(Status, &quot;Closed - Unconverted&quot;)  || ISPICKVAL(Status, &quot;Closed - Converted&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead First Assigned Date</fullName>
        <actions>
            <name>Set_Lead_First_Assigned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Assigned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Lead.First_Assignment_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
            <value>Unassigned Lead</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead First Attempt Date</fullName>
        <actions>
            <name>Update_Lead_First_Attempt_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Total_Outbound_Attempts__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Date/Time of the first attempt  - outbound email sent or outbound call is made</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Hand Raiser Change Alert</fullName>
        <actions>
            <name>Lead_Hand_Raiser_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email to the lead owner when the hand raiser type changes from null to a value or from one value to another value</description>
        <formula>AND (ISCHANGED( Hand_Raiser_Type__c ),  NOT( Owner:Queue.QueueName  = &quot;Unassigned Lead&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Last Assigned Date</fullName>
        <actions>
            <name>Update_Lead_Last_Assigned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Date/Time when the owner is set to a person, not a queue</description>
        <formula>AND(ISCHANGED(OwnerId ), NOT( ISBLANK( First_Assignment_Date__c ) ), PRIORVALUE(OwnerId)&lt;&gt; OwnerId,Owner:Queue.QueueName &lt;&gt; &apos;Unassigned Lead&apos;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Update Prior Owner</fullName>
        <actions>
            <name>Update_Lead_Prior_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Run when lead owner has been changed and prior</description>
        <formula>OwnerId  &lt;&gt;  PRIORVALUE( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove Lead Completed Date</fullName>
        <actions>
            <name>Lead_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a Closed - Unconverted lead is reopened, remove the lead completed date and the outcome.</description>
        <formula>AND(     OR ( ISPICKVAL(Status,&quot;Open&quot;),          ISPICKVAL(Status,&quot;To Call&quot;),            ISPICKVAL(Status,&quot;To Call Working&quot;)        ) , NOT(ISBLANK( Completed_Date__c )) , ISPICKVAL(PRIORVALUE(Status),&quot;Closed - Unconverted&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Existing Opp Outcome on Converted Lead</fullName>
        <actions>
            <name>Update_Existing_Opp_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set outcome to Existing Opportunity on Converted Lead when Existing Opportunity Id selected</description>
        <formula>AND( IsConverted , NOT (ISBLANK( Existing_Opportunity__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Last Attempt Date</fullName>
        <actions>
            <name>Update_Last_Attempt_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Lead Last Attempt Date to current date/time when the total outbound attempts count changes and the total outbound attempts count is &gt;= 1</description>
        <formula>AND(ISCHANGED(Total_Outbound_Attempts__c), Total_Outbound_Attempts__c  &gt;= 1)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Country State field</fullName>
        <actions>
            <name>Country_State_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISBLANK(Country_State_Code__c),ISCHANGED(CountryCode)     ,ISCHANGED(StateCode ),CONTAINS($Setup.Countries_Requiring_States__c.Countries_Requires_States__c,TEXT(CountryCode)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Lead Status based on Outcome</fullName>
        <actions>
            <name>Update_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>set the lead status if the outcome is set</description>
        <formula>ISCHANGED( Outcome__c ) &amp;&amp;   NOT(ISBLANK(TEXT(Outcome__c))) &amp;&amp; NOT(ISPICKVAL( Outcome__c ,&apos;Converted&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Outcome On Lead Conversion</fullName>
        <actions>
            <name>Update_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Upon successful conversion of lead (Lead Status is closed), set Outcome value to &quot;CONVERTED&quot;</description>
        <formula>AND(ISBLANK( Existing_Opportunity__c ), IsConverted )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
