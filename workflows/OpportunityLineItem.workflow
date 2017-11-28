<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_Consulting</fullName>
        <description>updates the revenue class on the opportunity product to Consulting</description>
        <field>Revenue_Class__c</field>
        <literalValue>Consulting</literalValue>
        <name>Opportunity Product Rev class-Consulting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_Perpetual</fullName>
        <description>updates the revenue class on the opportunity product to Perpetual</description>
        <field>Revenue_Class__c</field>
        <literalValue>Perpetual</literalValue>
        <name>Opportunity Product Rev class - Perpetua</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_SMS</fullName>
        <description>updates the revenue class on the opportunity SMS to Training</description>
        <field>Revenue_Class__c</field>
        <literalValue>SMS</literalValue>
        <name>Opportunity Product Rev class - SMS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_TermNew</fullName>
        <description>updates the revenue class on the opportunity product to Term New</description>
        <field>Revenue_Class__c</field>
        <literalValue>Term New</literalValue>
        <name>Opportunity Product Rev class - Term New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_Term_Ren</fullName>
        <description>updates the revenue class on the opportunity product to Term Renewal</description>
        <field>Revenue_Class__c</field>
        <literalValue>Term Renewal</literalValue>
        <name>Opportunity Product Rev class - Term Ren</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Product_Rev_class_Training</fullName>
        <description>updates the revenue class on the opportunity product to Training</description>
        <field>Revenue_Class__c</field>
        <literalValue>Training</literalValue>
        <name>Opportunity Product Rev class - Training</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Revenue Class Update%3A Consulting</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_Consulting</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>Consulting</value>
        </criteriaItems>
        <description>Defaults the revenue class to consulting on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Class Update%3A Perpetual</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_Perpetual</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>Perpetual</value>
        </criteriaItems>
        <description>Defaults the revenue class to perpetual on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Class Update%3A SMS</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_SMS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>SMS</value>
        </criteriaItems>
        <description>Defaults the revenue class to SMS on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Class Update%3A Term New</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_TermNew</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>Term New</value>
        </criteriaItems>
        <description>Defaults the revenue class to Term New on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Class Update%3A Term Renewal</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_Term_Ren</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>Term Renewal</value>
        </criteriaItems>
        <description>Defaults the revenue class to term renewal on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue Class Update%3A Training</fullName>
        <actions>
            <name>Opportunity_Product_Rev_class_Training</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Revenue_Class__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <description>Defaults the revenue class to training on the line item from a product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
