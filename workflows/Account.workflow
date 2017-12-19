<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPN_Account_Changed_Alert</fullName>
        <description>CPN Account Changed Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>CPN_Changes_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Ops_Notification_And_Alerts/CPN_Account_Changed</template>
    </alerts>
    <alerts>
        <fullName>test</fullName>
        <ccEmails>faina.gorelik@mathworks.com</ccEmails>
        <description>test</description>
        <protected>false</protected>
        <recipients>
            <recipient>MathWorks_Customer_Services</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sample_Email_Templates/ContactFollowUpSAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Export_Status_for_accounts</fullName>
        <description>The purpose of this rule is to set the export status for accounts. The workflow rule uses the &quot;Export Status Values&quot; Custom Settings to set the value to A (Export prohibited), C (End-use statement required) and D (No restrictions)</description>
        <field>Export_Status__c</field>
        <formula>IF(CONTAINS(  $Setup.Export_Status_Values__c.A_Country_Code__c  ,   TEXT( BillingCountryCode ) ), &quot;A&quot; , IF(CONTAINS(  $Setup.Export_Status_Values__c.C_CountryCodes__c  ,   TEXT( BillingCountryCode ) ), &quot;C&quot; , &quot;D&quot;))</formula>
        <name>Export Status for accounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetSiebelTerritoryIDToNA</fullName>
        <field>Siebel_Territory_ID__c</field>
        <formula>&quot;N/A&quot;</formula>
        <name>SetSiebelTerritoryIDToNA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetSiebelTerritoryIDToNULL</fullName>
        <field>Siebel_Territory_ID__c</field>
        <name>SetSiebelTerritoryIDToNULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Change_Name_Date</fullName>
        <description>Set the date when account name or account latin name was changed.</description>
        <field>Account_Name_Changed_Date__c</field>
        <formula>Now()</formula>
        <name>Set Account Change Name Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Prior_Territory_Changed_Date</fullName>
        <description>Stamp Date/Time when Account owner was changed</description>
        <field>Account_Prior_Territory_Changed_Date__c</field>
        <formula>Now()</formula>
        <name>Set Account Prior Territory Changed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Sector</fullName>
        <description>Set account sector to Commercial if it&apos;s null</description>
        <field>Account_Sector__c</field>
        <literalValue>Commercial</literalValue>
        <name>Set Account Sector</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Status_to_Active</fullName>
        <description>Set Account Status to Active when Kept Account name is removed</description>
        <field>Account_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Account Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Status_to_Duplicate</fullName>
        <description>Set account status automatically to duplicate when Kept account name is addded</description>
        <field>Account_Status__c</field>
        <literalValue>Duplicate</literalValue>
        <name>Set Account Status to Duplicate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Prior_Territory_id</fullName>
        <field>Account_Prior_Territory__c</field>
        <formula>CASESAFEID(PRIORVALUE(  Salesforce_Territory_Id__c  ))</formula>
        <name>Set Prior Territory Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Export_Status</fullName>
        <field>Export_Status__c</field>
        <name>Update Account Export Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Location</fullName>
        <description>Set account location for new account record or update the existing based on workflow fields</description>
        <field>Site</field>
        <formula>BillingCity &amp;&apos; &apos;&amp;  
IF(
    OR(
        Text(BillingCountryCode) =&apos;JP&apos;
        ,Text(BillingCountryCode) =&apos;KR&apos;
        ,Text(BillingCountryCode) =&apos;CN&apos;
    )
    ,Account_State_Province_Latin__c
    ,IF(
        Text(BillingCountryCode) =&apos;IN&apos;
        ,BillingState
        ,IF(
            OR(
                Text(BillingCountryCode) =&apos;AU&apos;
                ,Text(BillingCountryCode) =&apos;CA&apos;
                ,Text(BillingCountryCode) =&apos;IT&apos;
                ,Text(BillingCountryCode) =&apos;MX&apos;
                ,Text(BillingCountryCode) =&apos;US&apos;
            )
            ,Country_State_Code__c
            ,TEXT(BillingCountryCode)  
        )
    )    
)
&amp;&apos; &apos;&amp; Account_Sector_Code__c
&amp;&apos; &apos;&amp; IF(Text( Account_Status__c ) = &apos;Unvalidated&apos;,&apos;UV&apos;,&apos;&apos;)</formula>
        <name>Update Account Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bypass_Fuzzy_Matching_Flag_F</fullName>
        <description>Reset the Bypass Fuzzy Matching flag to false</description>
        <field>Bypass_Fuzzy_Matching__c</field>
        <literalValue>0</literalValue>
        <name>Update Bypass Fuzzy Matching Flag - F</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Industry_Vetted_Date</fullName>
        <field>Industry_Vetted_Date__c</field>
        <formula>Now()</formula>
        <name>Update Industry Vetted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Industry_Vetted_Login</fullName>
        <field>Industry_Vetted_Login__c</field>
        <formula>$User.Username</formula>
        <name>Update Industry Vetted Login</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>AccountOutboundMessage</fullName>
        <apiVersion>30.0</apiVersion>
        <description>outbound message action on the Account object that sends following fields:
a.	Source Table
b.	Event Type
c.	ID
d.	Is Address Changed</description>
        <endpointUrl>https://DONOTUSEsf-ext-msg.mathworks.com/sfdcaccountnotification/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>IsAddress_Changed__c</fields>
        <fields>Source_Table__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>AccountOutboundMessage</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Account Name Changed Date</fullName>
        <actions>
            <name>Set_Account_Change_Name_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Date/Time when account name or account latin name was changed</description>
        <formula>AND(OR(PRIORVALUE(Name) &lt;&gt; Name, PRIORVALUE( Account_Name_Latin__c ) &lt;&gt; Account_Name_Latin__c),NOT  ISNEW()  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account Status Auto Set to Duplicate</fullName>
        <actions>
            <name>Set_Account_Status_to_Duplicate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Kept Account Name field is populated, the Account status is automatically set to &quot;Duplicate&quot;.</description>
        <formula>NOT(ISBLANK( Kept_Account_Name__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AccountOutboundMessageRule</fullName>
        <actions>
            <name>AccountOutboundMessage</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>workflow rule on the Account object that executes on insert and every update</description>
        <formula>AND(     OR(         ISCHANGED(Name)         ,ISCHANGED(Controlled_Technology_Alert__c)         ,ISCHANGED(Denied_Company__c ) ,ISCHANGED(Is_Corporate_Parent__c)        ,ISCHANGED(Disable_Merge__c)         ,ISCHANGED(Export_Status__c)         ,ISCHANGED(CDS_Account_Id__c)         ,ISCHANGED(Industry)         ,ISCHANGED(Type)         ,ISCHANGED(Kept_Account_Siebel_Id__c)         ,ISCHANGED(Site)         ,ISCHANGED(Account_Name_Latin__c)         ,ISCHANGED(Account_Status__c)         ,ISCHANGED(Account_Sector__c)         ,ISCHANGED(Siebel_Account_Id__c)        ,ISCHANGED(Account_Warning__c)         ,ISCHANGED(Corporate_Parent_Name__c)         ,ISCHANGED(Website)         ,IsAddress_Changed__c     )     ,NOT(Is_Individual_Account__c)     ,$User.Id != &quot;005i00000014J7w&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Export Status</fullName>
        <actions>
            <name>Export_Status_for_accounts</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The purpose of this rule is to set the export status for accounts. The workflow rule uses the &quot;Export Status Values&quot; Custom Settings to set the value to A (Export prohibited), C (End-use statement required) and D (No restrictions)</description>
        <formula>AND(   TEXT(Account_Status__c)   &lt;&gt; &apos;InActive&apos;, ISCHANGED( BillingCountryCode ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset Bypass Fuzzy Matching Flag</fullName>
        <actions>
            <name>Update_Bypass_Fuzzy_Matching_Flag_F</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Bypass_Fuzzy_Matching__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rule to update the Bypass Fuzzy Matching flag on account. (Bypass Fuzzy Matching flag is only used during lead conversion so that the fuzzy matching scenario in DupeBlocker does not run on insert when the Account is being created.)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Account Warning%2FDenied Account Notification</fullName>
        <actions>
            <name>Account_Warning_Notes</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>Send reminded to the user who flagged Account Warning /Denied account to create a task with the more details regarding the warning</description>
        <formula>ISCHANGED( Denied_Company__c ) ||  ISCHANGED( Account_Warning__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Account Location</fullName>
        <actions>
            <name>Update_Account_Location</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set account location when new record created OR address fields(Country, State, City) OR Sector updated</description>
        <formula>OR(ISCHANGED (Account_Status__c ),ISCHANGED( Account_Sector__c ), ISCHANGED( BillingCity) , ISCHANGED( BillingCountry ), ISCHANGED( BillingState) ,ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Account Status to Active</fullName>
        <actions>
            <name>Set_Account_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Anytime Kept Account Id removed, set account status to Acitve</description>
        <formula>ISBLANK( Kept_Account_Name__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Default Sector</fullName>
        <actions>
            <name>Set_Account_Sector</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Sector__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set account default sector to Commercial</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Industry Vetted Fields</fullName>
        <actions>
            <name>Update_Industry_Vetted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Industry_Vetted_Login</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Industry_Vetted_Login__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set PriorTerritory Fields</fullName>
        <actions>
            <name>Set_Account_Prior_Territory_Changed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Prior_Territory_id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set prior account territoryid  and the date when prior territory was changed. Do not set the values if prior territory was null</description>
        <formula>AND(ISCHANGED(  Salesforce_Territory_Id__c ), PRIORVALUE(Salesforce_Territory_Id__c )&lt;&gt; Salesforce_Territory_Id__c ,NOT ISNULL(PRIORVALUE(Salesforce_Territory_Id__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetSiebelTerritoryIDToNAForIndividualAccount</fullName>
        <actions>
            <name>SetSiebelTerritoryIDToNA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Is_Individual_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set Siebel Territory ID to &apos;N/A&apos; if Account is Individual .</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetSiebelTerritoryIDToNullIfChangedFromIndividualToRegular</fullName>
        <actions>
            <name>SetSiebelTerritoryIDToNULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set the siebel territory id to null if the account changes from individual acct to regular account</description>
        <formula>AND(NOT(ISNEW()),NOT(Is_Individual_Account__c),  ISCHANGED( Is_Individual_Account__c ), Salesforce_Territory_Id__c=&quot;N/A&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Account_Warning_Notes</fullName>
        <assignedTo>sgagnon@mathworks.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Account Warning/Denied Notes Reminder</subject>
    </tasks>
</Workflow>
