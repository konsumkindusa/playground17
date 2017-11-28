<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Follow_up_T_C_Survey_1_agreement_role</fullName>
        <description>Follow up T&amp;C Survey 1 (agreement role)</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>survey_email_templates/T_C_renewal_reminder_HTML</template>
    </alerts>
    <alerts>
        <fullName>Follow_up_T_C_Survey_2_agreement_role</fullName>
        <description>Follow up T&amp;C Survey 2 (agreement role)</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/T_C_renewal_reminder_HTML</template>
    </alerts>
    <alerts>
        <fullName>Initial_SSL_Survey</fullName>
        <description>Initial SSL Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/SSL_survey_HTML</template>
    </alerts>
    <alerts>
        <fullName>Initial_T_C_Survey_agreement_role</fullName>
        <description>Initial T&amp;C Survey (agreement role)</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/T_C_renewal_HTML</template>
    </alerts>
    <alerts>
        <fullName>SSL_Reminder_1</fullName>
        <description>SSL Survey Reminder 1</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/SSL_survey_reminder</template>
    </alerts>
    <alerts>
        <fullName>SSL_Survey_Reminder_2</fullName>
        <description>SSL Survey Reminder 2</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>tsdonotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/SSL_survey_reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Response_Date_agreement_role</fullName>
        <description>makes the agreement T&amp;C survey response date null when the Send T&amp;C survey box is made true.</description>
        <field>T_C_Survey_Response_Date__c</field>
        <name>Clear Response Date (agreement role)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_SSL_Response_Date_agreement_role</fullName>
        <description>makes the SSL Response Date null on the partner agreement role record</description>
        <field>SSL_Survey_Response_Date__c</field>
        <name>Clear SSL Response Date (agreement role)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Send_SSL_Survey_Null</fullName>
        <description>Makes the Send SSL renewal field null</description>
        <field>Send_SSL_Renewal__c</field>
        <literalValue>0</literalValue>
        <name>Make Send SSL Survey Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Send_T_C_Survey_Null</fullName>
        <description>makes the Send T&amp;C survey field null</description>
        <field>Send_T_C_Renewal__c</field>
        <literalValue>0</literalValue>
        <name>Make Send T&amp;C Survey Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Remove Send SSL Survey Flag</fullName>
        <actions>
            <name>Make_Send_SSL_Survey_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement_Role__c.SSL_Survey_Response_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>used to make the send survey field null once a survey is received (T&amp;C Survey Response not = null)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Remove Send T%26C Survey Flag</fullName>
        <actions>
            <name>Make_Send_T_C_Survey_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement_Role__c.T_C_Survey_Response_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>used to make the send survey field null once a survey is received (T&amp;C Survey Response not = null)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send SSL Survey</fullName>
        <actions>
            <name>Initial_SSL_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_SSL_Response_Date_agreement_role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement_Role__c.Send_SSL_Renewal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email with a survey to renew SSL. Also triggers time based actions to send follow up emails until criteria are no longer met.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SSL_Reminder_1</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>SSL_Survey_Reminder_2</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
