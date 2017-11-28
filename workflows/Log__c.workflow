<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Matlab_Answer_Integration_Error_Notification</fullName>
        <ccEmails>sfdcsupport@mathworks.com</ccEmails>
        <description>Matlab Answer Integration Error Notification</description>
        <protected>false</protected>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Alert_Email_Templates/Matlab_Answer_Integration_Error_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Course_Manager_Response_Status</fullName>
        <description>Send Course Manager Response Status</description>
        <protected>false</protected>
        <recipients>
            <recipient>mwscheduler@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Alert_Email_Templates/Send_Course_Manager_Response_Status_Error</template>
    </alerts>
    <alerts>
        <fullName>Send_Publish_Assignment_Rule_Error_Notification</fullName>
        <description>Send Publish Assignment Rule Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mwscheduler@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Alert_Email_Templates/Send_Publish_Assignment_Rule_Error</template>
    </alerts>
    <alerts>
        <fullName>Training_Missing_Email_Template_Notification</fullName>
        <ccEmails>sfdcsupport@mathworks.com</ccEmails>
        <description>Training Missing Email Template Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>sshanbha@mathworks.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Training_Notification_Templates/Training_Missing_Template_error_notification</template>
    </alerts>
    <rules>
        <fullName>Send Course Manager Response Status</fullName>
        <actions>
            <name>Send_Course_Manager_Response_Status</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Log__c.Message__c</field>
            <operation>startsWith</operation>
            <value>Course Manager Integration Error</value>
        </criteriaItems>
        <description>Send the status of the Course Manager Integration if response code &lt;&gt; 200. 200 is OK</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Matlab Answer Integration Error Notification</fullName>
        <actions>
            <name>Matlab_Answer_Integration_Error_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Log__c.Message__c</field>
            <operation>startsWith</operation>
            <value>Matlab Answer Integration Exception</value>
        </criteriaItems>
        <description>Send email to sfdcsupport@mathworks.com for Matlab Answer Integration errors</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Publish Assignment Rule Error</fullName>
        <actions>
            <name>Send_Publish_Assignment_Rule_Error_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Log__c.Message__c</field>
            <operation>startsWith</operation>
            <value>Publish Assignment Rules Error</value>
        </criteriaItems>
        <description>Send email to sfdcsupport@mathworks.com for Publish Territory Assignment Rule Error</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Training Email Template Error Notification</fullName>
        <actions>
            <name>Training_Missing_Email_Template_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Log__c.StackTrace__c</field>
            <operation>contains</operation>
            <value>EnrollmentDML : CheckAndSendEmailNotification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Log__c.Message__c</field>
            <operation>startsWith</operation>
            <value>Customer Training Notification Error: Email Template does not exist</value>
        </criteriaItems>
        <description>Send email to sfdcsupport@mathworks.com when the template name derived in the email framework does not exist in the system</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
