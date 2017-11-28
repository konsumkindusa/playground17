<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Project_Team_Member_Assignment_Notification</fullName>
        <description>Project Team Member Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Resource__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AE_PE_Templates/TSR_Team_Member_Assignment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Project_Team_Member_Unique</fullName>
        <description>Hidden Field to validate that the Project Team Member only can be added once</description>
        <field>Duplicate_Team_Member__c</field>
        <formula>CASESAFEID(Project__r.Id) +  CASESAFEID(Resource__r.Id)</formula>
        <name>Project Team Member Unique</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Project Team Members of Assignment</fullName>
        <actions>
            <name>Project_Team_Member_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email notification to a project team member when they are initially added to the project team.</description>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Project Team Member Unique</fullName>
        <actions>
            <name>Project_Team_Member_Unique</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to ensure the the Project Team Member only can be added once</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
