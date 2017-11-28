<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Customer_Training_Distance_Learning_Notify</fullName>
        <ccEmails>trainops@mathworks.com</ccEmails>
        <description>Customer Training Distance Learning Notify</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/Customer_Training_Distance_Learning_Notify</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_For_Failing_Matlab_Associate_Exam</fullName>
        <description>Email Notification For Failing Matlab Associate Exam</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/MathWorks_Cert_MATLAB_Associate_Fail</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_For_Failing_Matlab_Professional_Exam</fullName>
        <description>Email Notification For Failing Matlab Professional Exam</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/MathWorks_Cert_MATLAB_Professional_Fail</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_For_Passing_Matlab_Associate_Exam</fullName>
        <description>Email Notification For Passing Matlab Associate Exam</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/MathWorks_Cert_MATLAB_Associate_PASS</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_For_Passing_Matlab_Professional_Exam</fullName>
        <description>Email Notification For Passing Matlab Professional Exam</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/MathWorks_Cert_MATLAB_Professional_PASS</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_Chinese</fullName>
        <description>L3 Training Survey - Chinese</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_Chinese</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_English</fullName>
        <description>L3 Training Survey - English</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_English</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_French</fullName>
        <description>L3 Training Survey - French</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_French</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_German</fullName>
        <description>L3 Training Survey - German</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_German</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_Italian</fullName>
        <description>L3 Training Survey - Italian</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_Italian</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_Japanese</fullName>
        <description>L3 Training Survey - Japanese</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_Japanese</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_Korean</fullName>
        <description>L3 Training Survey - Korean</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_Korean</template>
    </alerts>
    <alerts>
        <fullName>L3_Training_Survey_Spanish</fullName>
        <description>L3 Training Survey - Spanish</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/L3_Enrollment_Training_Survey_Spanish</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_Chinese_Enrollment_Training_Survey</fullName>
        <description>Survey - Send Chinese Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_Chinese</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_English_Enrollment_Training_Survey</fullName>
        <description>Survey - Send English Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_English</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_French_Enrollment_Training_Survey</fullName>
        <description>Survey - Send French Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_French</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_German_Enrollment_Training_Survey</fullName>
        <description>Survey - Send German Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_German</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_Italian_Enrollment_Training_Survey</fullName>
        <description>Survey - Send Italian Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_Italian</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_Japanese_Enrollment_Training_Survey</fullName>
        <description>Survey - Send Japanese Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_Japanese</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_Korean_Enrollment_Training_Survey</fullName>
        <description>Survey - Send Korean Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_Korean</template>
    </alerts>
    <alerts>
        <fullName>Survey_Send_Spanish_Enrollment_Training_Survey</fullName>
        <description>Survey - Send Spanish Enrollment Training Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Enrollee_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>survey_email_templates/Enrollment_Training_Survey_Spanish</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Enrollment_Cert_Exam_Agreement</fullName>
        <description>Sets the value in field Certification Exam Agreement to Awaiting Response when record created</description>
        <field>Certification_Exam_Agreement__c</field>
        <literalValue>Awaiting Response</literalValue>
        <name>Set Enrollment Cert Exam Agreement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_End_Date_to_Class_End</fullName>
        <description>Set Enrollment End Date to the related Class End Date. Used for non-Self-Paced classes.</description>
        <field>End_Date__c</field>
        <formula>Class__r.End_Date__c</formula>
        <name>Set Enrollment End Date to Class End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_End_Date_to_ETA_Start</fullName>
        <description>Set Enrollment End Date to the related Enterprise Training Agreement Term End Date</description>
        <field>End_Date__c</field>
        <formula>Enterprise_Training_Agreement__r.Term_End_Date__c</formula>
        <name>Set Enrollment End Date to ETA End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_End_Date_w_Duration</fullName>
        <description>Set Enrollment End Date based on TODAY + the Default Duration of the related Self-Paced Class.</description>
        <field>End_Date__c</field>
        <formula>TODAY() + IF(NOT(ISBLANK(Class__r.Default_Duration__c)),Class__r.Default_Duration__c,90)</formula>
        <name>Set Enrollment End Date w/ Duration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Expiration_Reminder</fullName>
        <description>Set the Enrollment Expiration Reminder from the related Class.  Used for Self-Paced Classes.</description>
        <field>Expiration_Reminder__c</field>
        <formula>Class__r.Expiration_Reminder__c</formula>
        <name>Set Enrollment Expiration Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_MW_Account_Id</fullName>
        <description>Set the value for field MW Account Id from the contact record&apos;s MathWorks Account Id</description>
        <field>MW_Account_ID__c</field>
        <formula>Enrollee_Name__r.MathWorks_Account_ID__c</formula>
        <name>Set Enrollment MW Account Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Seat_Price_from_Class</fullName>
        <description>Set Enrollment Seat Price from the related Class if the Seat Price is not explicitly set when the Enrollment is created</description>
        <field>Seat_Price__c</field>
        <formula>IF(ISBLANK(Seat_Price__c),Class__r.Seat_Price__c,Seat_Price__c)</formula>
        <name>Set Enrollment Seat Price from Class</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Send_Certificate_Flag</fullName>
        <description>Set Enrollment Send Certificate Flag from the related Class.</description>
        <field>Send_Certificate__c</field>
        <literalValue>1</literalValue>
        <name>Set Enrollment Send Certificate Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Send_Email_Flag</fullName>
        <description>Set the Enrollment Send Email Flag from the related Class.</description>
        <field>Send_Email__c</field>
        <literalValue>1</literalValue>
        <name>Set Enrollment Send Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Start_Date_to_Class_Start</fullName>
        <description>Set Enrollment Start Date to the Start Date of the related Class.  Used for non-Self-Paced Classes.</description>
        <field>Start_Date__c</field>
        <formula>Class__r.Start_Date__c</formula>
        <name>Set Enrollment Start Date to Class Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Start_Date_to_Today</fullName>
        <description>Set the Enrollment Start Date to Today. Primarily used for Self-Paced Classes.</description>
        <field>Start_Date__c</field>
        <formula>IF(ISBLANK(Start_Date__c), TODAY(), Start_Date__c)</formula>
        <name>Set Enrollment Start Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enrollment_Status_to_Cancelled</fullName>
        <field>Enrollment_Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Set Enrollment Status to Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Instructor_Led_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Instructor_Led</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Instructor Led Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_to_Distance_Learning</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Distance_Learning</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type to Distance Learning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Self_Paced_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Self_Paced</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Self-Paced Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Completion_Cert_Flag_True</fullName>
        <description>Set the Send Completion Certificate Flag to True</description>
        <field>Send_Completion_Certificate_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Set Send Completion Cert Flag True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Training_Survey_TRUE</fullName>
        <description>set the send training survey to true, this will kick off a process to send the email</description>
        <field>Send_Training_Survey__c</field>
        <literalValue>1</literalValue>
        <name>Set Send Training Survey = TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Awaiting_Payment_Notification</fullName>
        <description>Update the Send Awaiting Payment Notification flag to True</description>
        <field>Send_Awaiting_Payment_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update Awaiting Payment Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Cancelled_Notification</fullName>
        <description>Update the Send Cancelled Notification flag to True</description>
        <field>Send_Cancelled_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update Cancelled Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Enrollment_Status_Waitlisted</fullName>
        <description>Update the enrollment status to Waitlisted</description>
        <field>Enrollment_Status__c</field>
        <literalValue>Waitlisted</literalValue>
        <name>Update Enrollment Status Waitlisted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Passed_Test_Flag</fullName>
        <field>Passed_Test_Flag__c</field>
        <formula>IF( 
OR( 
AND( 
NOT(ISBLANK(Test_1_Score__c)) 
,NOT(ISBLANK(Test_1_Pass_Score__c)) 
,OR( 
ISBLANK(Test_2_Pass_Score__c) 
,Test_2_Pass_Score__c = 0 
) 
) 
,AND( 
NOT(ISBLANK(Test_1_Score__c)) 
,NOT(ISBLANK(Test_1_Pass_Score__c)) 
,NOT(ISBLANK(Test_2_Score__c)) 
,NOT(ISBLANK(Test_2_Pass_Score__c)) 
) 
) 
,IF( 
OR( 
AND( 
Test_2_Pass_Score__c &gt; 0 
,Test_2_Pass_Score__c &gt;=0 
,(Test_1_Score__c - Test_1_Pass_Score__c &gt;=0) 
,(Test_2_Score__c - Test_2_Pass_Score__c &gt;=0) 
) 
,AND( 
ISBLANK(Test_2_Pass_Score__c) 
,(Test_1_Score__c - Test_1_Pass_Score__c &gt;=0) 
) 
) 
,&apos;Y&apos; 
,&apos;N&apos; 
) 
, &apos;&apos; 
)</formula>
        <name>Update Passed Test Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Registered_Notification</fullName>
        <description>Update the Send Registered Notification flag to True</description>
        <field>Send_Registered_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update Registered Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Self_Paced_Expiration_Reminder</fullName>
        <description>Update the self-paced expiration reminder flag</description>
        <field>Send_Self_Paced_Expiration_Reminder__c</field>
        <literalValue>1</literalValue>
        <name>Update Self Paced Expiration Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Waitlisted_Notification</fullName>
        <description>Update the Send Waitlisted Notification flag to True</description>
        <field>Send_Waitlisted_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update Waitlisted Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_registered_AP_Notification</fullName>
        <description>Update the Send Registered - AP Notification flag to True</description>
        <field>Send_Registered_AP_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update registered AP Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Registered_Reminder_Flag</fullName>
        <field>Send_Registered_Reminder_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update the Registered Reminder Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Exam_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Exam</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to Exam Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Send_Enrollment_data_to_MHLM</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://sf-ext-msg.mathworks.com/SFDCEnrollmentNotificationService/soap/v1/</endpointUrl>
        <fields>Course_Code__c</fields>
        <fields>Email__c</fields>
        <fields>End_Date__c</fields>
        <fields>Enrollment_Status__c</fields>
        <fields>Id</fields>
        <fields>MW_Account_ID__c</fields>
        <fields>Name</fields>
        <fields>Start_Date__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>Send Enrollment data to MHLM</name>
        <protected>false</protected>
        <useDeadLetterQueue>true</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Customer Training Distance Learning Notify</fullName>
        <actions>
            <name>Customer_Training_Distance_Learning_Notify</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When the new enrollment for distance learning is created with status of Registered OR if an existing enrollment status is changed to Registered 3 days before the class start date, send an email to training operations group so they can send the course mate</description>
        <formula>AND(OR (IsNew(),ISCHANGED( Enrollment_Status__c )), Start_Date__c &lt; (  TODAY() + 4), Class__r.RecordType.Name = &quot;Distance Learning&quot;, ISPICKVAL(  Enrollment_Status__c , &apos;Registered&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Exam Passed Flag</fullName>
        <actions>
            <name>Update_Passed_Test_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to Calculate the Passed Flag for exam enrollment when the scores are entered</description>
        <formula>OR(ISCHANGED(Test_1_Score__c) , ISCHANGED(Test_2_Score__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Enrollment to Training Authorization</fullName>
        <actions>
            <name>Send_Enrollment_data_to_MHLM</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Workflow to pass self-paced enrollment data to Training Auth:
- Status is set to Registered on new or existing record
- MathWorks Acc ID is not null and &lt;&gt; 0
- End Date is changed
- Status is set to Cancelled
- MW Account ID is set to non null value</description>
        <formula>AND(      Format_Of_Class__c = &apos;Self-Paced&apos;      ,NOT(ISBLANK(Enrollee_Name__r.MathWorks_Account_ID__c))      ,NOT (Enrollee_Name__r.MathWorks_Account_ID__c = &apos;0&apos;)       ,OR(          AND(              ISCHANGED(Enrollment_Status__c)             ,ISPICKVAL(Enrollment_Status__c , &apos;Cancelled&apos;)             )             ,AND( 	     ISPICKVAL(Enrollment_Status__c, &apos;Registered&apos;) 	 	    ,OR(  	        ISNEW()  	       ,AND( 	            NOT(ISNEW()) 	           ,OR( 		        ISCHANGED(Enrollment_Status__c) 		       ,ISCHANGED(End_Date__c)                        , AND(                              ISCHANGED(MW_Account_ID__c)                             ,NOT(ISNULL(MW_Account_ID__c))                             ) 	               ) 	            ) 	   ) 	)   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Training Enrollment Survey</fullName>
        <actions>
            <name>Set_Send_Training_Survey_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>criteria to set the Send Training Enrollment Survey</description>
        <formula>AND( OR(ISNEW(), ISCHANGED( Enrollment_Status__c )), ISPICKVAL(Enrollment_Status__c, &quot;Completed&quot;), ISBLANK( Survey_Training_Survey_Last_Sent__c ), Class__r.Send_Enrollment_Surveys__c , OR(Class_Format__c = &quot;Instructor Led Online&quot;, Class_Format__c = &quot;Instructor Led Classroom&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Completion Cert Notification Flag</fullName>
        <actions>
            <name>Set_Send_Completion_Cert_Flag_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Completion Certificate Notification flag when an Enrollment is marked completed and the send certificate flag is checked.</description>
        <formula>AND(     OR(         ISNEW()         ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Completed&quot;))     )     ,ISPICKVAL(Enrollment_Status__c, &quot;Completed&quot;)     ,Send_Certificate__c     ,Send_Email__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Awaiting Payment Notification Flag</fullName>
        <actions>
            <name>Update_Awaiting_Payment_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Enrollment Notification flag when a new enrollment gets created with Awaiting Payment status or status on existing enrollment is changed to Awaiting Payment.</description>
        <formula>AND(     OR(         ISNEW()         ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Awaiting Payment&quot;))     )     ,ISPICKVAL(Enrollment_Status__c, &quot;Awaiting Payment&quot;)     ,Send_Email__c     ,AND(            NOT( Class_Status__c = &quot;Inactive&quot;)          , NOT(Class_Status__c = &quot;Cancelled&quot;)          )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Cancelled Notification Flag</fullName>
        <actions>
            <name>Update_Cancelled_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Enrollment Notification flag when a new enrollment gets created with Registered status or status on existing enrollment is changed to Registered.</description>
        <formula>AND(       NOT(ISNEW())     ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Cancelled&quot;))     ,ISPICKVAL(Enrollment_Status__c, &quot;Cancelled&quot;)     ,Send_Email__c     ,AND(         NOT( Class_Status__c = &quot;Inactive&quot;)       , NOT(Class_Status__c = &quot;Cancelled&quot;)        )      )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Properties%3A Distance Learning</fullName>
        <actions>
            <name>Set_Enrollment_End_Date_to_Class_End</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Seat_Price_from_Class</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Start_Date_to_Class_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Record_Type_to_Distance_Learning</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set default enrollment properties including start and end dates and record type for Distance Learning Class Enrollments.</description>
        <formula>Class__r.Format_Of_Class__c = &quot;Distance Learning&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Properties%3A Exam</fullName>
        <actions>
            <name>Set_Enrollment_Cert_Exam_Agreement</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_End_Date_to_Class_End</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Seat_Price_from_Class</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Start_Date_to_Class_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_Exam_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set default enrollment properties including start and end dates and Record Types for Exam Class Enrollments.</description>
        <formula>Class__r.Format_Of_Class__c = &quot;Exam&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Properties%3A Instructor Led</fullName>
        <actions>
            <name>Set_Enrollment_End_Date_to_Class_End</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Seat_Price_from_Class</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Start_Date_to_Class_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Instructor_Led_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set default enrollment properties including start and end dates and record type for Instructor Led Class Enrollments.</description>
        <formula>Class__r.Format_Of_Class__c = &quot;Instructor Led&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Properties%3A SP w%2F Training Agreement</fullName>
        <actions>
            <name>Set_Enrollment_End_Date_to_ETA_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Expiration_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_MW_Account_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Start_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Self_Paced_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set default enrollment properties including start and end dates and record type for Self-Paced Enrollments under an Enterprise Training Agreement</description>
        <formula>AND( NOT(ISBLANK(Enterprise_Training_Agreement__c)) ,Class__r.Format_Of_Class__c = &quot;Self-Paced&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Properties%3A SP w%2Fo Training Agreement</fullName>
        <actions>
            <name>Set_Enrollment_End_Date_w_Duration</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Expiration_Reminder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_MW_Account_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Seat_Price_from_Class</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enrollment_Start_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Self_Paced_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set default enrollment properties including start and end dates and record type for Self-Paced Enrollments NOT under an Enterprise Training Agreement</description>
        <formula>AND( ISBLANK(Enterprise_Training_Agreement__c) ,Class__r.Format_Of_Class__c = &quot;Self-Paced&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Registered AP Notification Flag</fullName>
        <actions>
            <name>Update_registered_AP_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Enrollment Notification flag when a new enrollment gets created with Registered - Awaiting Payment  status or status on existing enrollment is changed to Registered - Awaiting Payment.</description>
        <formula>AND(     OR(         ISNEW()         ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Registered - Awaiting Payment&quot;))     )     ,ISPICKVAL(Enrollment_Status__c, &quot;Registered - Awaiting Payment&quot;)     ,Send_Email__c     ,AND(         NOT( Class_Status__c = &quot;Inactive&quot;)       , NOT(Class_Status__c = &quot;Cancelled&quot;)        ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Registered Notification Flag</fullName>
        <actions>
            <name>Update_Registered_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Enrollment Notification flag when a new enrollment gets created with Registered status or status on existing enrollment is changed to Registered.</description>
        <formula>AND(     OR(         ISNEW()         ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Registered&quot;))     )     ,ISPICKVAL(Enrollment_Status__c, &quot;Registered&quot;)     ,Send_Email__c      ,AND(           NOT( Class_Status__c = &quot;Inactive&quot;)         , NOT(Class_Status__c = &quot;Cancelled&quot;)         ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Registered Reminder Notification Flag</fullName>
        <active>true</active>
        <description>Set registered reminder notification flag 7 days prior to the class start date which will be used to trigger reminder email to enrollees enrolled in Instructor Led, Distance Learning or Exam format class</description>
        <formula>AND(   OR(       Class__r.Format_Of_Class__c  = &apos;Instructor Led&apos;    ,Class__r.Format_Of_Class__c  = &apos;Distance Learning&apos;    ,Class__r.Format_Of_Class__c  = &apos;Exam&apos;     )    , ISPICKVAL(Enrollment_Status__c ,&apos;Registered&apos;)    ,  ISPICKVAL(Class__r.Status__c ,&apos;Active&apos;)    , Send_Email__c = True    ,  (Start_Date__c -7) &gt; TODAY() )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_the_Registered_Reminder_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Enrollment__c.Start_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Enrollment Send Certificate Flag</fullName>
        <actions>
            <name>Set_Enrollment_Send_Certificate_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Class__c.Send_Certificate__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set Enrollment Send Certificate Flag from the related Class.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Send Email Flag</fullName>
        <actions>
            <name>Set_Enrollment_Send_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Enrollment Send Email Flag from the related Class.</description>
        <formula>AND(Enterprise_Training_Agreement__c == null, Class__r.Send_Email__c == True)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Status - Certificate Agreement</fullName>
        <actions>
            <name>Set_Enrollment_Status_to_Cancelled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Enrollment__c.Certification_Exam_Agreement__c</field>
            <operation>equals</operation>
            <value>Decline</value>
        </criteriaItems>
        <description>Update the enrollment status to Cancelled if the certification exam agreement is set to Decline</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Enrollment Waitlisted Notification Flag</fullName>
        <actions>
            <name>Update_Waitlisted_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the Send Enrollment Notification flag when a new enrollment gets created with Waitlisted status or status on existing enrollment is changed to Waitlisted.</description>
        <formula>AND(     OR(         ISNEW()         ,NOT(ISPICKVAL(PRIORVALUE(Enrollment_Status__c), &quot;Waitlisted&quot;))     )     ,ISPICKVAL(Enrollment_Status__c, &quot;Waitlisted&quot;)     ,Send_Email__c     ,AND(        NOT( Class_Status__c = &quot;Inactive&quot;)      , NOT(Class_Status__c = &quot;Cancelled&quot;)      )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Self Paced Expiration Reminder Flag</fullName>
        <active>true</active>
        <description>Workflow to set the self paced expiration reminder flag on enrollment which will invoke the reminder email</description>
        <formula>AND(     Format_Of_Class__c = &quot;Self-Paced&quot;,     Class_Status__c = &quot;Active&quot;,     Send_Email__c ,     ISPICKVAL(Enrollment_Status__c , &quot;Registered&quot;),     Self_Paced_Exp_Reminder_Date__c &gt; TODAY()      )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Self_Paced_Expiration_Reminder</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Enrollment__c.Self_Paced_Exp_Reminder_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
