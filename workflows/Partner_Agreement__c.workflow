<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert</fullName>
        <description>Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>MW_Focal_Point__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>X10_Install_English/Install_Closing_E</template>
    </alerts>
    <alerts>
        <fullName>Send_Pre_Product_Survey_reminder</fullName>
        <description>Send Pre-Product Survey reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>connections@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Pre_Product_Survey_Template_CNX</template>
    </alerts>
    <alerts>
        <fullName>Send_SSL_Usage_Survey_reminder</fullName>
        <description>Send SSL Usage Survey reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>connections@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/SSL_Survey_Template_CNX</template>
    </alerts>
    <alerts>
        <fullName>send_email_to_Contact_for_Pre_Product_Survey</fullName>
        <description>send email to Contact for Pre-Product Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>connections@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Pre_Product_Survey_Template_CNX</template>
    </alerts>
    <alerts>
        <fullName>send_email_to_Contact_for_SSL_Usage_Survey</fullName>
        <description>send email to Contact for SSL Usage Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>connections@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/SSL_Survey_Template_CNX</template>
    </alerts>
    <alerts>
        <fullName>send_email_to_Contact_for_T_C_Survey</fullName>
        <description>send email to Contact for T&amp;C Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>connections@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/T_C_renewal_HTML</template>
    </alerts>
    <fieldUpdates>
        <fullName>Agreement_status_date_updated</fullName>
        <description>update when the agreement status changed</description>
        <field>Agreement_Status_Updated__c</field>
        <formula>NOW ()</formula>
        <name>Agreement status date updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Did_not_respond_to_PP_Survey</fullName>
        <description>Clear when the Survey is sent</description>
        <field>Pre_product_no_response__c</field>
        <literalValue>0</literalValue>
        <name>Clear Did not respond to PP Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Did_not_respond_to_SSL_Use_Survey</fullName>
        <description>Clear when the Survey is sent</description>
        <field>SSL_Usage_No_Response__c</field>
        <literalValue>0</literalValue>
        <name>Clear Did not respond to SSL Use Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Did_not_respond_to_T_C_Survey</fullName>
        <description>Clear when the Survey is sent</description>
        <field>T_C_No_Response__c</field>
        <literalValue>0</literalValue>
        <name>Clear Did not respond to T&amp;C Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Send_Pre_Product_Survey_to_NULL</fullName>
        <description>Make Send Pre-Product Survey to NULL</description>
        <field>Pre_product_send__c</field>
        <literalValue>0</literalValue>
        <name>Make Send Pre-Product Survey to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Send_SSL_Usage_Survey_to_NULL</fullName>
        <description>Make Send SSL Usage Survey to NULL</description>
        <field>SSL_Usage_Send__c</field>
        <literalValue>0</literalValue>
        <name>Make Send SSL Usage Survey to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Did_not_respond_to_PP_Survey_to_NUL</fullName>
        <description>will set Did not respond to Pre-Product Survey  to False</description>
        <field>Pre_product_no_response__c</field>
        <literalValue>0</literalValue>
        <name>Mark Did not respond to PP Survey to NUL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Did_not_respond_to_SSL_Survey_to_NU</fullName>
        <description>will set Did not respond to SSL Usage Survey to False</description>
        <field>SSL_Usage_No_Response__c</field>
        <literalValue>0</literalValue>
        <name>Mark Did not respond to SSL Survey to NU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Did_not_respond_to_T_C_Survey_NULL</fullName>
        <description>will set Did not respond to T&amp;C Survey to False</description>
        <field>T_C_No_Response__c</field>
        <literalValue>0</literalValue>
        <name>Mark Did not respond to T&amp;C Survey NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Send_Pre_Prod_Survey_to_NULL</fullName>
        <description>trigger when the Did not respond flag is set to True</description>
        <field>Pre_product_send__c</field>
        <literalValue>0</literalValue>
        <name>Mark Send Pre-Prod Survey to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Send_SSL_Usage_Survey_to_NULL</fullName>
        <description>trigger when the Did not respond flag is set to True</description>
        <field>SSL_Usage_Send__c</field>
        <literalValue>0</literalValue>
        <name>Mark Send SSL Usage Survey to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Send_T_C_Survey_to_NULL</fullName>
        <description>trigger when the Did not respond flag is set to True</description>
        <field>T_C_Send__c</field>
        <literalValue>0</literalValue>
        <name>Mark Send T&amp;C Survey to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Unresponsive_to_Pre_Prod_Surv_NULL</fullName>
        <description>Used to make the send survey field null once a survey is received</description>
        <field>Pre_product_no_response__c</field>
        <literalValue>0</literalValue>
        <name>Mark Unresponsive to Pre-Prod Surv NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pre_Product_Survey_Status_to_New</fullName>
        <field>Pre_Product_Status__c</field>
        <literalValue>New</literalValue>
        <name>Set Pre-Product Survey Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pre_Product_Survey_Status_to_Sent</fullName>
        <description>sets the Pre-Product Survey Status to Sent</description>
        <field>Pre_Product_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>Set Pre_Product Survey Status to Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SSL_Usage_Survey_Last_Sent</fullName>
        <description>Set the Date to TODAY when the email is sent that inlcudes the Survey</description>
        <field>SSL_Usage_Sent_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set SSL Usage Survey Last Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SSL_Usage_Survey_Status_to_New</fullName>
        <field>SSL_Usage_Status__c</field>
        <literalValue>New</literalValue>
        <name>Set SSL Usage Survey Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SSL_Usage_Survey_Status_to_Sent</fullName>
        <description>sets the SSL Usage Survey Status to Sent</description>
        <field>SSL_Usage_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>Set SSL Usage Survey Status to Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_T_C_Survey_Status_to_New</fullName>
        <field>T_C_Status__c</field>
        <literalValue>New</literalValue>
        <name>Set T&amp;C Survey Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_T_C_Survey_Status_to_Sent</fullName>
        <description>sets the T&amp;C Survey Status to Sent</description>
        <field>T_C_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>Set T&amp;C Survey Status to Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>et_Did_not_respond_to_T_C_survey_TRUE</fullName>
        <description>check the Did not respond to T&amp;C Survey</description>
        <field>T_C_No_Response__c</field>
        <literalValue>1</literalValue>
        <name>et Did not respond to T&amp;C survey TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Did_not_respond_to_Pre_Prod_survey_t</fullName>
        <description>check the Did not respond to Pre_product Survey</description>
        <field>Pre_product_no_response__c</field>
        <literalValue>1</literalValue>
        <name>set Did not respond to Pre-Prod survey t</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Did_not_respond_to_SSL_survey</fullName>
        <description>check the Did not respond to SSL Survey Survey</description>
        <field>SSL_Usage_No_Response__c</field>
        <literalValue>1</literalValue>
        <name>set Did not respond to SSL survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Pre_Product_Survey_Last_Sent</fullName>
        <description>set the Date to TODAY when the email is sent that inlcudes the Survey</description>
        <field>Pre_Product_sent_date__c</field>
        <formula>TODAY ()</formula>
        <name>set Pre-Product Survey Last Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_T_C_Survey_Last_Sent</fullName>
        <description>set the Date to TODAY when the email is sent that inlcudes the Survey</description>
        <field>T_C_Sent_Date__c</field>
        <formula>TODAY ()</formula>
        <name>set T&amp;C Survey Last Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_the_Status_Changed_to_Active</fullName>
        <description>Update the Status Changed to Active to NOW</description>
        <field>Status_Updated_to_Active__c</field>
        <formula>now ()</formula>
        <name>update the Status Changed to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Remove Send Pre-Product Survey Flag</fullName>
        <actions>
            <name>Make_Send_Pre_Product_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Did_not_respond_to_PP_Survey_to_NUL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Pre_Product_Survey_Status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to make the send survey field null once a survey is received (Pre-Product Response Date not = null)</description>
        <formula>ISCHANGED ( Pre_Product_Response_date__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove Send SSL Usage Survey Flag</fullName>
        <actions>
            <name>Make_Send_SSL_Usage_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Did_not_respond_to_SSL_Survey_to_NU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_SSL_Usage_Survey_Status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to make the send survey field null once a survey is received (SSL Usage Response Date not = null)</description>
        <formula>ISCHANGED (  SSL_Usage_Response_Date__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove Send T%26C Survey Flag</fullName>
        <actions>
            <name>Mark_Did_not_respond_to_T_C_Survey_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Send_T_C_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_T_C_Survey_Status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to make the send survey field null once a survey is received (T&amp;C Response Date not = null)</description>
        <formula>ISCHANGED ( T_C_Response_Date__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Pre-Product Email</fullName>
        <actions>
            <name>send_email_to_Contact_for_Pre_Product_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Did_not_respond_to_PP_Survey</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Pre_Product_Survey_Status_to_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>set_Pre_Product_Survey_Last_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement__c.Pre_product_send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>trigger to send an email which includes a survey link</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Pre_Product_Survey_reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_Pre_Product_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Pre_Product_Survey_reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_Pre_Product_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>set_Did_not_respond_to_Pre_Prod_survey_t</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send SSL-Usage Email</fullName>
        <actions>
            <name>send_email_to_Contact_for_SSL_Usage_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Did_not_respond_to_SSL_Use_Survey</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_SSL_Usage_Survey_Last_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_SSL_Usage_Survey_Status_to_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement__c.SSL_Usage_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>trigger to send an email which includes a survey link</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>set_Did_not_respond_to_SSL_survey</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_SSL_Usage_Survey_reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_SSL_Usage_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_SSL_Usage_Survey_reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_SSL_Usage_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send T%26C Email</fullName>
        <actions>
            <name>send_email_to_Contact_for_T_C_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Did_not_respond_to_T_C_Survey</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_T_C_Survey_Status_to_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>set_T_C_Survey_Last_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement__c.T_C_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>trigger to send an email which includes a survey link</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>send_email_to_Contact_for_T_C_Survey</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_T_C_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>send_email_to_Contact_for_T_C_Survey</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>set_T_C_Survey_Last_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>et_Did_not_respond_to_T_C_survey_TRUE</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Status is changed to Active</fullName>
        <actions>
            <name>update_the_Status_Changed_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Agreement__c.Status__c</field>
            <operation>equals</operation>
            <value>Active,Active - No Web Page</value>
        </criteriaItems>
        <description>trigger to update the date when the status is changed to Active*</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unresponsive to Pre-Prod Promo set to NULL</fullName>
        <actions>
            <name>Mark_Send_Pre_Prod_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when the unresponsive to Pre-Product Flag flag is set to True</description>
        <formula>AND ( ISCHANGED( Pre_product_no_response__c ), (Pre_product_no_response__c = TRUE) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unresponsive to SSL Usage Promo set to NULL</fullName>
        <actions>
            <name>Mark_Send_SSL_Usage_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when the unresponsive to SSL Usage Flag flag is set to True</description>
        <formula>AND ( ISCHANGED(  SSL_Usage_No_Response__c  ), ( SSL_Usage_No_Response__c  = TRUE) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unresponsive to T%26C set to NULL</fullName>
        <actions>
            <name>Mark_Send_T_C_Survey_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger when the unresponsive to T&amp;C Flag flag is set to True</description>
        <formula>AND ( ISCHANGED(  T_C_No_Response__c  ), ( T_C_No_Response__c = TRUE) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Agreement Status change</fullName>
        <actions>
            <name>Agreement_status_date_updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>trigger to populate the date and time of when the agreement status last changed</description>
        <formula>ISCHANGED(Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
