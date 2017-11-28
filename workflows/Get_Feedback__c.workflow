<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Case_Owner_when_a_Service_Survey_is_received</fullName>
        <description>Email Case Owner when a Service Survey is received</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Case_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>service@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/service_survey_email_to_manager</template>
    </alerts>
    <alerts>
        <fullName>Send_Prerelease_Survey_Email_from_GFB</fullName>
        <description>Send Prerelease Survey Email - from GFB</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Prerelease_Survey_template_From_GFB_HTML</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Get_Feedback_Contact_for_Survey</fullName>
        <description>Send email to Get Feedback Contact for Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Author_License_Survey</template>
    </alerts>
    <alerts>
        <fullName>email_the_Primary_Sales_rep_for_a_survey</fullName>
        <description>email the Primary Sales rep for a survey</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Primary_Sales_Rep_email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/service_survey_email_to_sales</template>
    </alerts>
    <alerts>
        <fullName>email_the_manager_when_Service_Survey_is_receive</fullName>
        <description>email the manager when Service Survey is received</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Owner_Manager_email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/service_survey_email_to_manager</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_License_Survey_Status_to_Sent</fullName>
        <description>set the status to sent once teh survey is sent</description>
        <field>License_Survey_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>Set License Survey Status to Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Prerelease_to_False_on_GFB</fullName>
        <field>Prerelease_Survey_Send_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Set Send Prerelease to False - on GFB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>case_manager_update</fullName>
        <field>Service_Owner_Manager_email__c</field>
        <formula>case__r.Owner:User.Manager.Email</formula>
        <name>case manager update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_license_survey_status_to_New</fullName>
        <description>set the license survey status to New when the survey is received</description>
        <field>License_Survey_Status__c</field>
        <literalValue>New</literalValue>
        <name>set license survey status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Owner has manager and is not a Queue</fullName>
        <actions>
            <name>email_the_manager_when_Service_Survey_is_receive</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>case_manager_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR(  NOt (ISBLANK(case__r.Owner:User.Manager.Email )),  NOT(case__r.Owner_Name__c = &quot;Unassigned&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prerelease survey date changed</fullName>
        <actions>
            <name>Set_Send_Prerelease_to_False_on_GFB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when a Prerelease survey is received</description>
        <formula>NOT( ISBLANK( Prerelease_Survey_Date_Survey_Received__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Author License Renewal Survey</fullName>
        <actions>
            <name>Send_email_to_Get_Feedback_Contact_for_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_License_Survey_Status_to_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Get_Feedback__c.Send_Author_License_Renewal_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>to send the author licnse survey</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Prerelease Survey - from GFB</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Get_Feedback__c.Prerelease_Survey_Send_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>used to trigger an email to send the Prerelease Survey</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Prerelease_Survey_Email_from_GFB</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Send_Prerelease_to_False_on_GFB</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Get_Feedback__c.Prerelease_Activation_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Prerelease_Survey_Email_from_GFB</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Get_Feedback__c.Prerelease_Activation_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>license Survey is received</fullName>
        <actions>
            <name>set_license_survey_status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>will trigger updates when a new author license survey is revceived</description>
        <formula>ISCHANGED( License_Survey_Received__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
