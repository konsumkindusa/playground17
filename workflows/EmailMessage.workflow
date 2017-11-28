<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_First_Contact_Date_Update</fullName>
        <field>First_Contact_Date__c</field>
        <formula>IF(ISNull( Parent.First_Contact_Date__c ),Now(),Parent.First_Contact_Date__c)</formula>
        <name>Case First Contact Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Insert_For_Approval_Tag_on_Subject</fullName>
        <field>Subject</field>
        <formula>Subject + &quot;-[For Approval]-&quot;</formula>
        <name>Insert For Approval Tag on Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_For_Approval_Tag</fullName>
        <field>Subject</field>
        <formula>SUBSTITUTE(Subject, &quot;-[For Approval]-&quot;, &quot;&quot;)</formula>
        <name>Remove For Approval Tag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Last_Activity_Date</fullName>
        <description>Update Case Last Activity Date when new Outbound Email has been sent, exclude auto response outbound emails</description>
        <field>Last_Activity_Date__c</field>
        <formula>Now()</formula>
        <name>Update Case Last Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Sub_Status</fullName>
        <field>SubStatus__c</field>
        <literalValue>Waiting for Internal</literalValue>
        <name>Update Case Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_issecure_field</fullName>
        <description>this will update issecure field on case when ever an email with attachment arrives in system</description>
        <field>isSecured__c</field>
        <literalValue>0</literalValue>
        <name>Update issecure field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Email Update Activity Last Date</fullName>
        <actions>
            <name>Update_Case_Last_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Case Activity Last date field every time when new Outbound Email has been send. Exclude Auto Response</description>
        <formula>AND(  ISPICKVAL (Status, &quot;Sent&quot;), NOT(CONTAINS(FromName , &quot;Auto Response&quot;)), CONTAINS(ToAddress, Parent.Contact.Email),  Incoming = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Update Case first contact date</fullName>
        <actions>
            <name>Case_First_Contact_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set now on case first contact date when first outbound email ( not auto reply) was sent to the customer and from name is not auto response</description>
        <formula>AND(  ISPICKVAL (Status, &quot;Sent&quot;), NOT(CONTAINS(FromName , &quot;Auto Response&quot;)), CONTAINS(ToAddress, Parent.Contact.Email),  Incoming = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Email Message Closed Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <description>Set to Now custom field Closed Date/Time when Email status changed to Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set First Case Activity Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromName</field>
            <operation>notContain</operation>
            <value>Auto Response</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Test1</fullName>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <description>Test1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Sub Status for escalated emails</fullName>
        <actions>
            <name>Update_Case_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>DEVID</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>will update Case Sub Status for Task escalated emails</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Email Message Closed Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update issecure field</fullName>
        <actions>
            <name>Update_issecure_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.HasAttachment</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>this will update is issecure field on case whenever an email with attachment  s arrive to system</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
