<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contact_Country_Code_Update</fullName>
        <description>field update to update country_code__c with the value of contact.mailingcountrycode</description>
        <field>Country_Code__c</field>
        <formula>IF( ISBLANK(TEXT(MailingCountryCode)) , Self_Identified_Country__c ,  TEXT(MailingCountryCode))</formula>
        <name>Contact.Country Code Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Status_Set_to_Active</fullName>
        <field>Contact_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Contact Status Set to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Status_Set_to_Duplicate</fullName>
        <description>Sets the contact status to &apos;Duplicate&apos;</description>
        <field>Contact_Status__c</field>
        <literalValue>Duplicate</literalValue>
        <name>Contact Status Set to Duplicate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Department_Update</fullName>
        <description>updates department field</description>
        <field>Department</field>
        <formula>IF( ISBLANK( Department ) , Lead_Department__c, Department)</formula>
        <name>Department Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contact_Status_to_Active</fullName>
        <description>Update Contact Status to active when kept contact name removed</description>
        <field>Contact_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Contact Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>ContactOutboundMessage</fullName>
        <apiVersion>30.0</apiVersion>
        <description>2.	Create an outbound message action on the Contact object that sends following fields:
a.	Source Table
b.	Event Type
c.	ID
d.	Is Address Changed
e.	Is Account Changed</description>
        <endpointUrl>https://DONOTUSEsf-ext-msg.mathworks.com/sfdccontactnotification/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>Source_Table__c</fields>
        <fields>isAccount_Changed__c</fields>
        <fields>isAddress_Changed__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>ContactOutboundMessage</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Contact Status Auto Set to Duplicate</fullName>
        <actions>
            <name>Contact_Status_Set_to_Duplicate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Kept Contact Name field is populated, the contact status is automatically set to &quot;Duplicate&quot;.</description>
        <formula>NOT(ISBLANK( Kept_Contact_Name__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact Status From Duplicate to Active If Cleared Out</fullName>
        <actions>
            <name>Contact_Status_Set_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Kept Contact Name field is cleared out/set to NULL, the contact status is automatically set from &quot;Duplicate&quot; to &quot;Active&quot;</description>
        <formula>AND(        ISBLANK( Kept_Contact_Name__c ),        ISPICKVAL(  Contact_Status__c, &apos;Duplicate&apos;)   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ContactOutboundMessageRule</fullName>
        <actions>
            <name>ContactOutboundMessage</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>workflow rule on the Contact object that executes on insert and every update</description>
        <formula>AND(     OR(         ISNEW()         ,ISCHANGED(AccountId)         ,ISCHANGED(Advisory_Board__c)         ,ISCHANGED(Contact_Role__c)         ,ISCHANGED(Denied_On_Watch_List_checkbox__c)         ,ISCHANGED(Department)         ,ISCHANGED(Disable_Merge__c)         ,ISCHANGED(Email)         ,ISCHANGED(Employee_Flag__c)         ,ISCHANGED(Export_Prohibited_checkbox__c)         ,ISCHANGED(LastName)         ,ISCHANGED(FirstName)         ,ISCHANGED(Greeting__c)         ,ISCHANGED(CDS_Contact_Id__c)         ,ISCHANGED(Title)         ,ISCHANGED(Duplicate_of_Contact__c)         ,ISCHANGED(Department_Latin__c)         ,ISCHANGED(Last_Name_Latin__c)         ,ISCHANGED(First_Name_Latin__c)         ,ISCHANGED(Job_Title_Latin__c)         ,ISCHANGED(Mail_Stop_Latin__c)         ,ISCHANGED(Has_Licenses__c)         ,ISCHANGED(Mail_Stop__c)         ,ISCHANGED(Middle_Name__c)         ,ISCHANGED(Language__c)         ,ISCHANGED(Contact_Status__c)         ,ISCHANGED(Salutation)         ,ISCHANGED(Student_School_Name__c)         ,ISCHANGED(Siebel_Contact_Id__c)         ,ISCHANGED(Student__c)         ,ISCHANGED(Contact_Warnings__c)         ,ISCHANGED(MathWorks_Account_ID__c)         ,ISCHANGED(Web_Profile_Status__c)         ,ISCHANGED(Phone)         ,ISCHANGED(MobilePhone)         ,ISCHANGED(Fax)         ,isAddress_Changed__c        )     ,$User.Id != &quot;005i00000014J7w&quot;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Contact Warning%2FDenied Notification</fullName>
        <actions>
            <name>Contact_Warning_Denied_Notes_Reminder</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>Send a reminder to the DB team to add notes about why the Contact&apos;s Warnings or Denied Status has changed.</description>
        <formula>ISCHANGED(  Contact_Warnings__c  ) || ISCHANGED(  Denied_On_Watch_List_checkbox__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Country Code</fullName>
        <actions>
            <name>Contact_Country_Code_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>used to update the custom country code field based on the mailing address country code field.  This is used in the secure artifacts job.</description>
        <formula>1==1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update contact department</fullName>
        <actions>
            <name>Department_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>updates the standard department field on contact from the Lead Department field on contact (used for lead conversion) only if the standard department field on the contact is not already populated.</description>
        <formula>ISNEW() ||  ISCHANGED( Lead_Department__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Contact_Warning_Denied_Notes_Reminder</fullName>
        <assignedTo>sgagnon@mathworks.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Contact Warning/Denied Notes Reminder</subject>
    </tasks>
</Workflow>
