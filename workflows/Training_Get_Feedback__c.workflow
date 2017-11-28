<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>L3_High_NPS_Kudos_to_Managers</fullName>
        <ccEmails>Sarang.Ghormare@mathworks.com</ccEmails>
        <ccEmails>Euclid.Jorda@mathworks.com</ccEmails>
        <ccEmails>Dennis.Atwood@mathworks.com</ccEmails>
        <description>L3 High NPS Kudos to Managers</description>
        <protected>false</protected>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Kudos_Alert_for_an_Instructor</template>
    </alerts>
    <alerts>
        <fullName>L3_Low_NPS_Alert_to_Managers</fullName>
        <ccEmails>Sarang.Ghormare@mathworks.com</ccEmails>
        <ccEmails>Euclid.Jorda@mathworks.com</ccEmails>
        <ccEmails>Dennis.Atwood@mathworks.com</ccEmails>
        <description>L3 Low NPS Alert to Managers</description>
        <protected>false</protected>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Low_NPS_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_training_get_feedback_owner_to_queue</fullName>
        <description>Set the training get feedback record owner to queue. Process Builder would set the owner to the instructor.</description>
        <field>OwnerId</field>
        <lookupValue>Training_Survey_Unassigned</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set training get feedback owner to queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Training Survey Owner queue assignment</fullName>
        <actions>
            <name>Set_training_get_feedback_owner_to_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The owner for the training get feedback record will be set to queue if the class primary instructor does not have a user record</description>
        <formula>ISBLANK( Class__r.Instructor_User__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
