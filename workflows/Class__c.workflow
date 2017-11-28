<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Customer_Training_Class_Cancelled_Location_Cancel</fullName>
        <ccEmails>trainops@mathworks.com</ccEmails>
        <description>Customer Training Class Cancelled Location Cancel</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Proctor__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/Customer_Training_Class_Cancelled_Location_Cancel</template>
    </alerts>
    <alerts>
        <fullName>Customer_Training_New_Class_has_been_activated</fullName>
        <description>Customer Training New Class has been activated</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Training_Notification_Templates/Customer_Training_New_Class_has_been_activated</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_instructors_with_survey_links</fullName>
        <description>Send email to instructors with survey links</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Instructor__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>training@mathworks.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Training_Notification_Templates/Send_survey_link_to_instructors</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Class_End_date_to_Exam_Date</fullName>
        <description>Set Class End date to Exam Date</description>
        <field>End_Date__c</field>
        <formula>Exam_Date__c</formula>
        <name>Set Class End date to Exam Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Class_Start_date_to_Exam_Date</fullName>
        <description>Set Class Start date to Exam Date</description>
        <field>Start_Date__c</field>
        <formula>Exam_Date__c</formula>
        <name>Set Class Start date to Exam Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_GTR_Flag_Value_to_True</fullName>
        <description>Set the Field to true if a newly created class has Self-Paced and Distance Learning Record Type.</description>
        <field>Guaranteed_to_Run__c</field>
        <literalValue>1</literalValue>
        <name>Set GTR Flag Value to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_to_TDS_to_False</fullName>
        <field>Send_to_TDS__c</field>
        <literalValue>0</literalValue>
        <name>Set Send to TDS to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>ClassOutboundMessage</fullName>
        <apiVersion>38.0</apiVersion>
        <endpointUrl>https://sf-ext-msg.mathworks.com/ProductTrainingWs/soap/v1/</endpointUrl>
        <fields>Id</fields>
        <fields>Source_Table__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mwsf_integration@mathworks.com</integrationUser>
        <name>ClassOutboundMessage</name>
        <protected>false</protected>
        <useDeadLetterQueue>true</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>ClassOutboundMessageRule</fullName>
        <actions>
            <name>Set_Send_to_TDS_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ClassOutboundMessage</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>WF to call outbound message when a Public class is created with Active status OR when specific fields on a Public class are updated.</description>
        <formula>AND( 	ISPICKVAL(Class_Type__c, &apos;Public&apos;) 	,OR( 	   AND(  		   ISNEW() 		  , ISPICKVAL(Status__c , &apos;Active&apos;) 		   ) 			, ISCHANGED(Name) 			, ISCHANGED( Class_Type__c ) 			, ISCHANGED( Start_Date__c ) 			, ISCHANGED( End_Date__c ) 			, ISCHANGED( Start_Time__c ) 			, ISCHANGED( End_Time__c ) 			, ISCHANGED( Default_Duration__c ) 			, ISCHANGED( Days__c ) 			, ISCHANGED( Sponsor_Office__c ) 			, ISCHANGED( Publish_To_Web__c ) 			, ISCHANGED( Max_Seats__c ) 			, ISCHANGED( Open_Seats__c ) 			, ISCHANGED( Language__c ) 			, ISCHANGED( Guaranteed_to_Run__c ) 			, ISCHANGED( Training_Location__c ) 			, ISCHANGED( Status__c ) 			, Send_to_TDS__c = TRUE  	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Training New Class has been activated</fullName>
        <actions>
            <name>Customer_Training_New_Class_has_been_activated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>We want to email the instructor that a class has been created and marked active for onsite classes.</description>
        <formula>AND(     OR      (        ISPICKVAL(Class_Format__c,&apos;Instructor Led Classroom&apos;)      , ISPICKVAL(Class_Format__c,&apos;Instructor Led Online&apos;)      )  ,  ISPICKVAL(Status__c, &apos;Active&apos;)  ,  ISPICKVAL( Class_Type__c , &apos;Onsite&apos;)  ,  OR( ISNEW()  ,  ISCHANGED(Status__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Training Survey Link to Instructors</fullName>
        <active>true</active>
        <description>Send the survey links to instructors 48 hours before the class starts</description>
        <formula>AND( OR( ISPICKVAL(Class_Format__c , &quot;Instructor Led Classroom&quot;) ,ISPICKVAL(Class_Format__c , &quot;Instructor Led Online&quot;) ) , ISPICKVAL(Status__c, &quot;Active&quot;) ,NOT(ISBLANK(Primary_Instructor__c )) , (Start_Date__c -2) &gt; TODAY() )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_email_to_instructors_with_survey_links</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Class__c.Start_Date__c</offsetFromField>
            <timeLength>-48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Class GTR Flag to True</fullName>
        <actions>
            <name>Set_GTR_Flag_Value_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will set a field Guarantee To Run to true under specified conditions.</description>
        <formula>AND( 	NOT(Guaranteed_to_Run__c) 	,ISPICKVAL(Status__c,&quot;Active&quot;) 	,OR( 		ISNEW() 		,ISCHANGED(Class_Type__c) 		,ISCHANGED(Training_Location__c) 		,ISCHANGED(Status__c) 		,ISCHANGED(Enrollee_Seats_Taken__c) 		,ISCHANGED(Additional_Seats_Taken__c) 	) 	,OR( 		ISPICKVAL(Class_Format__c,&quot;Self-Paced Online&quot;) 		,AND( 			ISPICKVAL(Class_Type__c,&quot;Public&quot;) 			,OR( 				Location_Type__c = &quot;Corporate Training Center&quot; 				,ISPICKVAL(Class_Format__c,&quot;Instructor Led Online&quot;) 				,Total_Seats_Taken__c &gt;= 5				 			)	 		) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Class Start and End Date</fullName>
        <actions>
            <name>Set_Class_End_date_to_Exam_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Class_Start_date_to_Exam_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Class__c.Exam_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This WFR set the Class Start and End Date equal to the Exam Date</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
