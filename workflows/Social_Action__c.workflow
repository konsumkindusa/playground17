<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Grant_Letter_to_Owner_of_Social_Action</fullName>
        <description>Send Grant Letter to Owner of Social Action</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>socialmission@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Social_Mission/Grant_Award_Letter_auto</template>
    </alerts>
    <alerts>
        <fullName>Send_email_for_A_Thon_Payment_Request_to_Kevin_when_status_equals_Pending_Approv</fullName>
        <ccEmails>Kevin.Lorenc@mathworks.com,</ccEmails>
        <ccEmails>Natalie.Saroufim@mathworks.com,</ccEmails>
        <ccEmails>socialmission@mathworks.com</ccEmails>
        <description>Send email for A-Thon Payment Request to Kevin when status equals Pending Approval</description>
        <protected>false</protected>
        <senderAddress>socialmission@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Social_Mission/A_Thon_Matching_Approval_to_Kevin1</template>
    </alerts>
    <alerts>
        <fullName>email_Contact_when_Athon_Approved</fullName>
        <description>email Contact when Athon = Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>socialmission@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Social_Mission/A_Thon_approved_email_to_requestor</template>
    </alerts>
    <alerts>
        <fullName>send_auto_reply_for_Social_Action_to_the_Contact</fullName>
        <description>send auto reply for Social Action to the Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>socialmission@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Social_Mission/Social_Action_Auto_Reply</template>
    </alerts>
    <alerts>
        <fullName>send_email_when_Grant_equals_Processing_Payment</fullName>
        <ccEmails>Kevin.Lorenc@mathworks.com,</ccEmails>
        <ccEmails>Natalie.Saroufim@mathworks.com,</ccEmails>
        <ccEmails>socialmission@mathworks.com</ccEmails>
        <description>send email when Grant equals Processing Payment</description>
        <protected>false</protected>
        <senderAddress>socialmission@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Social_Mission/Grant_Payment_Request_to_Kevin_HTML</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Status_to_Spam</fullName>
        <description>Set the Status to Spam</description>
        <field>Status__c</field>
        <literalValue>Spam</literalValue>
        <name>Set Status to Spam</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Start_Date_set_to_Create_Date</fullName>
        <description>set the Start Date to the Create Date</description>
        <field>Start_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Start Date set to Create Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send A-Thon Payment Request email to Kevin</fullName>
        <actions>
            <name>Send_email_for_A_Thon_Payment_Request_to_Kevin_when_status_equals_Pending_Approv</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Social_Action__c.Category__c</field>
            <operation>equals</operation>
            <value>A-Thon</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.MathWorks_Office__c</field>
            <operation>equals</operation>
            <value>Natick,US - All,US - LA,US - Natick,US - Novi</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Type__c</field>
            <operation>equals</operation>
            <value>Awards</value>
        </criteriaItems>
        <description>Send A-Thon Payment Request email to Kevin</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Social Action is New</fullName>
        <actions>
            <name>Start_Date_set_to_Create_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Determines if the Social Action is new</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>send A-thon requestor email once Approved</fullName>
        <actions>
            <name>email_Contact_when_Athon_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Social_Action__c.Category__c</field>
            <operation>equals</operation>
            <value>A-Thon</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.MathWorks_Office__c</field>
            <operation>equals</operation>
            <value>Natick,US - All,US - LA,US - Natick,US - Novi</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Type__c</field>
            <operation>notEqual</operation>
            <value>General Inquiry</value>
        </criteriaItems>
        <description>Send the Contact on the A-Thon Social Action an email when the Status EQUALS Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>send Grant Award Letter</fullName>
        <actions>
            <name>Send_Grant_Letter_to_Owner_of_Social_Action</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Social_Action__c.Category__c</field>
            <operation>equals</operation>
            <value>Community Grants</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.MathWorks_Office__c</field>
            <operation>equals</operation>
            <value>Natick,US - All,US - LA,US - Natick,US - Novi</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Type__c</field>
            <operation>notEqual</operation>
            <value>General Inquiry</value>
        </criteriaItems>
        <description>Send the Owner an email to include the letter ti mail with the check</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>send Grant approval email</fullName>
        <actions>
            <name>send_email_when_Grant_equals_Processing_Payment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Social_Action__c.Category__c</field>
            <operation>equals</operation>
            <value>Community Grants</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Payment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.MathWorks_Office__c</field>
            <operation>equals</operation>
            <value>Natick,US - All,US - LA,US - Natick,US - Novi</value>
        </criteriaItems>
        <criteriaItems>
            <field>Social_Action__c.Type__c</field>
            <operation>equals</operation>
            <value>Awards</value>
        </criteriaItems>
        <description>send Grant approval email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>set Status to Spam</fullName>
        <actions>
            <name>Set_Status_to_Spam</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Social_Action__c.Pillar__c</field>
            <operation>equals</operation>
            <value>Spam</value>
        </criteriaItems>
        <description>When Pillar EQUALS Spam change Status to Spam</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
