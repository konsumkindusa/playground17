<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Article_Approval_Published_Email_Alert</fullName>
        <description>Article Approval Published Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Email_Alert_Email_Templates/Article_Approval_Published</template>
    </alerts>
    <alerts>
        <fullName>Article_Rejection_Email</fullName>
        <description>Article Approval Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Email_Alert_Email_Templates/Article_Approval_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Uncheck_Customer_Channel</fullName>
        <description>Marks the customer channel as FALSE</description>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Uncheck Customer Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Article_to_be_sent</fullName>
        <description>Set the article to be sent to true</description>
        <field>Article_To_Be_Sent__c</field>
        <formula>&apos;true&apos;</formula>
        <name>Update Article to be sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MW_Last_Modified_By</fullName>
        <field>MW_Last_Modified_By__c</field>
        <formula>LastModifiedBy.FirstName &amp;&apos; &apos;&amp; LastModifiedBy.LastName</formula>
        <name>Update MW Last Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MW_Last_Modified_By_Id</fullName>
        <field>MW_Last_Modified_By_ID__c</field>
        <formula>LastModifiedBy.Id</formula>
        <name>Update MW Last Modified By Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_customer_channel</fullName>
        <description>Updates the customer channel value to True</description>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Update customer channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Publish_New_Ver</fullName>
        <action>PublishAsNew</action>
        <description>publishes a new version of an article</description>
        <label>Publish New Ver</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>Publish_New_Ver1</fullName>
        <action>PublishAsNew</action>
        <description>publishes a new version of an article</description>
        <label>Publish New Ver</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>Publish_Update</fullName>
        <action>Publish</action>
        <description>re-publishes an article (updates) the existing version</description>
        <label>Publish - Update</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Exclude from Customer Channel</fullName>
        <actions>
            <name>Uncheck_Customer_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FAQ__kav.ValidationStatus</field>
            <operation>notEqual</operation>
            <value>Externally Validated</value>
        </criteriaItems>
        <criteriaItems>
            <field>FAQ__kav.IsVisibleInCsp</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Marks an article as NOT available in the customer channel if the validation status is NOT Validated external</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internally validated - set send articles flag to true</fullName>
        <actions>
            <name>Update_Article_to_be_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FAQ__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Internally Validated</value>
        </criteriaItems>
        <criteriaItems>
            <field>FAQ__kav.IsVisibleInCsp</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>FAQ__kav.Answers_URL__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Marks an article as NOT available in the customer channel if the validation status is Internally validated and AnswersURL is not null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Publish to customer channel</fullName>
        <actions>
            <name>Update_Article_to_be_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_customer_channel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FAQ__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Externally Validated</value>
        </criteriaItems>
        <description>Marks an article as available in the customer channel if the validation status is Validated external</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set FAQ Last Modified By</fullName>
        <actions>
            <name>Update_MW_Last_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_MW_Last_Modified_By_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update custom FAQ field MW Last Modified By field to the system last modified. For MW Scheduled and MW Integration users  keeps the original Last Modified by</description>
        <formula>NOT (CONTAINS( $Setup.Aricle_Exclude_Modified_By__c.User_Name__c , LastModifiedBy.Username) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
