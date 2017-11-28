<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Book_Promotion_Reminder</fullName>
        <description>Book Promotion Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Book_Program_promo</template>
    </alerts>
    <alerts>
        <fullName>Initial_Book_Promotion_Survey</fullName>
        <description>Initial Book Promotion Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Book_Program_promo</template>
    </alerts>
    <alerts>
        <fullName>Send_Status_Update_Survey_to_Book_Contact</fullName>
        <description>Send Status Update Survey to Book Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>donotreply@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Status_Update_Survey_Template_Book_Program</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Send_BP_Survey</fullName>
        <description>Clears Send Book Promo Survey when UNresponsive is checked</description>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Clear Send BP Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Send_Book_Promo_Survey</fullName>
        <description>Clear Send BP promo Suvery</description>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Clear Send Book Promo Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Unresponsive_to_BP_Survey</fullName>
        <description>Clear when Send Book Program is checked</description>
        <field>Unresponsive_to_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Clear Unresponsive to BP Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Unresponsive_to_Status_Update_Surv</fullName>
        <description>Clear when the Status Update Survey - Send is checked</description>
        <field>Status_Update_Survey_Unresponsive__c</field>
        <literalValue>0</literalValue>
        <name>Clear Unresponsive to Status Update Surv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Send_Book_Promotion_Survey_Null</fullName>
        <description>Makes the Send Book Promotion Survey Null</description>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Make Send Book Promotion Survey Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark</fullName>
        <description>will set Unresponsive to Book program to False</description>
        <field>Unresponsive_to_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Mark Unresponsive to BP Survey NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_BP_Promo_responsive_date_time_NULL</fullName>
        <description>set the Book Program Promo Date to NULL</description>
        <field>Book_Promotion_Response_Date_Time__c</field>
        <name>Mark BP Promo responsive date/time NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Send_BP_Promo_to_NULL</fullName>
        <description>Update Send Book P rogram Promo to NULL</description>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>Mark Send BP Promo to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Send_Status_Update_to_NULL</fullName>
        <description>Update Status Update Survey - Send to NULL</description>
        <field>Status_Update_Survey_Send__c</field>
        <literalValue>0</literalValue>
        <name>Mark Status Update - Send to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_as_Unresponsive_Book_Project</fullName>
        <description>Makes the unresponsive to book promotion field true.</description>
        <field>Unresponsive_to_Book_Promotion_Survey__c</field>
        <literalValue>1</literalValue>
        <name>Mark as Unresponsive (Book Project)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Promotional_Survey_Status_to_NULL</fullName>
        <description>sets the Promotional Survey Status to NULL when a new Survey is sent</description>
        <field>Promotional_Survey_Status__c</field>
        <name>Set Promotional Survey Status to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Book_Promo_Survey_to_True</fullName>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>1</literalValue>
        <name>Set Send Book Promo Survey to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Update_Survey_Last_Sent</fullName>
        <description>sets the date to Today when the Status Update Survey is sent</description>
        <field>Status_Update_Survey_Last_sent_date__c</field>
        <formula>TODAY ()</formula>
        <name>Set Status Update Survey - Last Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Update_Survey_Status_to_NULL</fullName>
        <field>Status_Update_Survey_Status__c</field>
        <name>Set Status Update Survey Status to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Update_Survey_Status_to_new</fullName>
        <field>Status_Update_Survey_Status__c</field>
        <literalValue>New</literalValue>
        <name>Set Status Update Survey - Status to new</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Update_Survey_Unresponsive</fullName>
        <description>set to true</description>
        <field>Status_Update_Survey_Unresponsive__c</field>
        <literalValue>1</literalValue>
        <name>Set Status Update Survey Unresponsive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Changed_field_update</fullName>
        <description>pdates the Current Status field to now when the Status is changed</description>
        <field>Status_Updated_Date__c</field>
        <formula>now()</formula>
        <name>Status Changed field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Book_Language_to_English</fullName>
        <description>set the Book Language to English</description>
        <field>Book_Language__c</field>
        <literalValue>English</literalValue>
        <name>Update Book Language to English</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Promo_Survey_Status_to_New</fullName>
        <field>Promotional_Survey_Status__c</field>
        <literalValue>New</literalValue>
        <name>set Promo Survey Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_last_Book_Promo_Survey_Last_SEnt</fullName>
        <description>identifies when the last Book Promotional Survey is sent</description>
        <field>Book_Promotional_Survey_Last_Sent__c</field>
        <formula>TODAY ()</formula>
        <name>Set Last Book Promo Survey Last Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test</fullName>
        <field>Send_Book_Promotion_Survey__c</field>
        <literalValue>0</literalValue>
        <name>test</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Book Program - Queue Book Promo Survey</fullName>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Book_Project__c.Status__c</field>
            <operation>equals</operation>
            <value>Developing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Book_Project__c.OwnerId</field>
            <operation>notContain</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Book_Project__c.OwnerId</field>
            <operation>notContain</operation>
            <value>China</value>
        </criteriaItems>
        <criteriaItems>
            <field>Book_Project__c.Send_Book_Promotion_Survey__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Send_Book_Promo_Survey_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Book_Project__c.Expected_Publication_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Book Project Status is changed</fullName>
        <actions>
            <name>Status_Changed_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to capture when the status changes on an Book Project</description>
        <formula>OR( ISNEW(), ISCHANGED(Status__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Default Book Language on creation</fullName>
        <actions>
            <name>Update_Book_Language_to_English</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Book_Project__c.OwnerId</field>
            <operation>equals</operation>
            <value>Book Project - Natick</value>
        </criteriaItems>
        <description>Default the Book Language when a New Project is created to English if the Owner = Queue of Book Project - Natick</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Remove Send Book Promotion Survey Flag</fullName>
        <actions>
            <name>Make_Send_Book_Promotion_Survey_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>set_Promo_Survey_Status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to make the send survey field null once a survey is received (Book Promotion Response Date not = null)</description>
        <formula>ISCHANGED( Book_Promotion_Response_Date_Time__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove Status Update Survey - Send Flag</fullName>
        <actions>
            <name>Clear_Unresponsive_to_Status_Update_Surv</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Send_Status_Update_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_Update_Survey_Status_to_new</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to make the send survey field null once a survey is received (Status Update Survey Response Date not = null)</description>
        <formula>ISCHANGED( Status_Update_Survey_Response_Date_Tim__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Book Promotion Survey</fullName>
        <actions>
            <name>Initial_Book_Promotion_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Unresponsive_to_BP_Survey</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Promotional_Survey_Status_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>set_last_Book_Promo_Survey_Last_SEnt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Book_Project__c.Send_Book_Promotion_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email linking to the book promotion survey (GetFeedback). Once the criteria are met, the book promotion response date field will be nulled by field update and an email sent to the related contact.  This workflow also triggers time based actions t</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Book_Promotion_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_last_Book_Promo_Survey_Last_SEnt</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Send_Book_Promo_Survey</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Mark_as_Unresponsive_Book_Project</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Book_Promotion_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_last_Book_Promo_Survey_Last_SEnt</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Status Update Survey</fullName>
        <actions>
            <name>Send_Status_Update_Survey_to_Book_Contact</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Unresponsive_to_Status_Update_Surv</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_Update_Survey_Last_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_Update_Survey_Status_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Book_Project__c.Status_Update_Survey_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email linking to the Status Update Survey (GetFeedback). Once the criteria are met, the Status Survey response date field will be nulled by field update and an email sent to the related contact.  This workflow also triggers time based actions</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Status_Update_Survey_to_Book_Contact</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Status_Update_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Status_Update_Survey_to_Book_Contact</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Status_Update_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_Update_Survey_Unresponsive</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Unresponsive to BP Promo set to NULL</fullName>
        <actions>
            <name>Mark_Send_BP_Promo_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when the unresponsive to Book Program flag is set to True</description>
        <formula>AND (ISCHANGED( Unresponsive_to_Book_Promotion_Survey__c),  (Unresponsive_to_Book_Promotion_Survey__c = TRUE))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unresponsive to Status Update set to NULL</fullName>
        <actions>
            <name>Mark_Send_Status_Update_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when the unresponsive to Status Update flag is set to True</description>
        <formula>AND (ISCHANGED( Status_Update_Survey_Unresponsive__c ),  (Status_Update_Survey_Unresponsive__c  = TRUE))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
