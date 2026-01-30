/**
* @File Name : AZSC_ScheduleEmailAlerts.cls
* @Description :
* @Author : Oliver
* @Last Modified By : Oliver
* @Last Modified On : September 24, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 24, 2025 |   | Initial Version
**/
 
global class AZSC_ScheduleEmailAlerts implements Schedulable, Database.Batchable<sObject> {
    public String query;
    public Map<String,Object> paramKeytoValue;
	public AZSC_ScheduleEmailAlerts(String query, Map<String,Object> paramKeytoValue) {
        this.query = query;
		this.paramKeytoValue = paramKeytoValue;
    }
	global void execute(SchedulableContext sc) {
		//Business License - Certificatie 90 Day Renewal Reminder
        //Run Everyday at 4am
        /*Integer dayNum = 90;
        System.schedule('ABS Renewal 90 day Reminder Job', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'ABS_Renewal_90_Day_Reminder_1758696730521', 'sObjectName' => 'BusinessLicense', 'senderEmail' => 'ABS Email'}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'ABS_Renewal_90_Day_Reminder_1758696730521', 'sObjectName' => 'BusinessLicense', 'senderEmail' => 'ABS Email'}));*/
        
        //Business License - Certificatie 30 Day Renewal Reminder
        //Run Everyday at 4am
        /*Integer dayNum = 30;
        System.schedule('ABS Renewal 30 day Reminder Job', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'ABS_Renewal_30_Day_Reminder_1758696996570', 'sObjectName' => 'BusinessLicense', 'senderEmail' => 'ABS Email'}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'ABS_Renewal_30_Day_Reminder_1758696996570', 'sObjectName' => 'BusinessLicense', 'senderEmail' => 'ABS Email'}));*/
        
        //Business License - Licensing CRI Renewal 7 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 7;
        System.schedule('Licensing CRI Renewal 7 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'Licensing_CRI_Renewal_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'Licensing_CRI_Renewal_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
        
        //Business License - Licensing CR Renewal 60 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 60;
        System.schedule('Licensing CR Renewal 60 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_60_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_60_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
        
        // Business License - CR Renewal Second Month Reminder Email
        // Runs everyday at 4am
        // Integer dayNum = 28;
        /*System.schedule('CR Renewal Second Month Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
        //Business License - LCR Renewal Second Month 14 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 14;
        System.schedule('LCR Renewal Second Month 14 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_14_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_14_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
        //Business License - CR Renewal Second Month 7 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 7;
        System.schedule('CR Renewal Second Month 7 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (PeriodEnd > NEXT_N_DAYS:' + (dayNum - 2) + ' AND PeriodEnd = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
   
        //Business License - CR Renewal Second Month 1 Day Reminder Email
        //Run Everyday at 4am
       /* System.schedule('CR Renewal Second Month 1 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c + '\' AND PeriodEnd = TODAY', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_1_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c + '\' AND PeriodEnd = TODAY', new Map<String,Object>{'templateName' => 'CR_Renewal_Second_Month_1_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
   
         //Business License - CR Renewal First Month 14 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 14;
        System.schedule('CR Renewal First Month 14 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (Late_Fee_From__c > NEXT_N_DAYS:' + (dayNum - 2) + ' AND Late_Fee_From__c = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_14_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (Late_Fee_From__c > NEXT_N_DAYS:' + (dayNum - 2) + ' AND Late_Fee_From__c = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_14_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
         //Business License - CR Renewal First Month 7 Day Reminder Email
        //Run Everyday at 4am
        /*Integer dayNum = 7;
        System.schedule('CR Renewal First Month 7 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (Late_Fee_From__c > NEXT_N_DAYS:' + (dayNum - 2) + ' AND Late_Fee_From__c = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\' AND (Late_Fee_From__c > NEXT_N_DAYS:' + (dayNum - 2) + ' AND Late_Fee_From__c = NEXT_N_DAYS:' + (dayNum - 1) + ')', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_7_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
         //Business License - CR Renewal First Month 1 Day Reminder Email
        //Run Everyday at 4am
        /*System.schedule('CR Renewal First Month 1 Day Reminder Email', '0 0 4 1/1 * ? *', new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c + '\' AND Late_Fee_From__c = TODAY', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_1_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));
        Database.executeBatch(new AZSC_ScheduleEmailAlerts('SELECT Id FROM BusinessLicense WHERE Status = \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c + '\' AND Late_Fee_From__c = TODAY', new Map<String,Object>{'templateName' => 'CR_Renewal_First_Month_1_Day_Reminder_Email', 'sObjectName' => 'BusinessLicense', 'senderEmail' => AZSC_Constant__mdt.getInstance('OrgWideEmail').Value__c}));*/
        
    	Database.executeBatch(new AZSC_ScheduleEmailAlerts(query, paramKeytoValue));
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> records) {
        List<sObject> createSObjs = new List<sObject>();
		List<EmailTemplate> templates = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName =: ''+paramKeytoValue.get('templateName')];
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> orgWideEmails = [SELECT Id,Address,DisplayName,Purpose,IsVerified,IsAllowAllProfiles FROM OrgWideEmailAddress WHERE IsVerified = true AND DisplayName =: ''+paramKeytoValue.get('senderEmail')];
        if(''+paramKeytoValue.get('sObjectName') == 'BusinessLicense') {
            Set<String> keys = new Set<String>();
            If(paramKeytoValue.get('senderEmail') == 'ABS Email') {
                for(Case_Relationship__c participant : [SELECT Id,Business_License__c,Email_Address__c,Person_Account__r.PersonContactId FROM Case_Relationship__c WHERE Business_License__c IN: records AND Role__c IN ('Designated Principal', 'Compliance Lawyer') AND Do_not_Send_Sub_Application__c = false]) {
                    if(!keys.contains(participant.Business_License__c+''+participant.Email_Address__c)) {
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(participant.Person_Account__r.PersonContactId);
                        if(!templates.isEmpty())
                            message.setTemplateId(templates[0].Id);
                        message.setToAddresses(new List<String>{participant.Email_Address__c});
                        message.setSaveAsActivity(false);          
                        message.setWhatId(participant.Business_License__c);
                        if(!orgWideEmails.isEmpty())
                            message.setOrgWideEmailAddressId(orgWideEmails[0].Id);
                        messages.add(message);
                    }
                    else
                        keys.add(participant.Business_License__c+''+participant.Email_Address__c);
                }
            }
            else {
                for(BusinessLicense Business:[Select Id,ContactId,contact.Email,RegulatoryAuthorizationType.name,RegulatoryAuthorizationType.Expiration_Day__c,RegulatoryAuthorizationType.Expiration_Month__c From BusinessLicense Where Id In :records]) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(Business.ContactId);
                    if(!templates.isEmpty())
                        message.setTemplateId(templates[0].Id);
                    message.setSaveAsActivity(true);          
                    message.setWhatId(Business.Id); 
                    if(!orgWideEmails.isEmpty())
                    message.setOrgWideEmailAddressId(orgWideEmails[0].Id);
                    //message= AZSC_EmailTemplateMerger.mergeContent(message, templates[0], Business);
                    messages.add(message);
                }
            }
        }
        /*for(sObject sObj : records) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId((String)sObj.get('ContactId'));
            if(!templates.isEmpty())
                message.setTemplateId(templates[0].Id);
            message.setToAddresses(new List<String>{(String)sObj.getSobject('Contact').get('Email')});
            message.setSaveAsActivity(false);          
            message.setWhatId((String)sObj.get('Id'));
            if(!orgWideEmails.isEmpty())
                message.setOrgWideEmailAddressId(orgWideEmails[0].Id);
            messages.add(message);
        }*/
        if(!messages.isEmpty() && !Test.isRunningTest())
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    global void finish(Database.BatchableContext BC) {}
}