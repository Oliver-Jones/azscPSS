global class AZSC_ScheduleUpdateRecords implements Schedulable, Database.Batchable<sObject> {
	public String query;
    public Map<String,Object> paramKeytoValue;
    public AZSC_ScheduleUpdateRecords(String query, Map<String,Object> paramKeytoValue) {
        this.query = query;
        this.paramKeytoValue = paramKeytoValue;
    }
    global void execute(SchedulableContext sc) {
		
        //Business License Applications - Abandonment Job
        //Run Everyday at 2am
        //use the following script
        //System.schedule('BLAs Abandonment Job', '0 0 2 1/1 * ? *', new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicenseApplication WHERE (Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusNotPaid').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusNew').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusPending').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusRequestInfo').Value__c+'\') AND Is_Expired__c = true AND Status != \''+AZSC_Constant__mdt.getInstance('ApplicationStatusAbandoned').Value__c+'\')', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('ApplicationStatusAbandoned').Value__c}));
        //Database.executeBatch(new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicenseApplication WHERE (Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusNotPaid').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusNew').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusPending').Value__c+'\' OR Status = \''+AZSC_Constant__mdt.getInstance('ApplicationStatusRequestInfo').Value__c+'\') AND Is_Expired__c = true AND Status != \''+AZSC_Constant__mdt.getInstance('ApplicationStatusAbandoned').Value__c+'\'', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('ApplicationStatusAbandoned').Value__c}));
    	
        //Business Licenses - Open Renewal Job
        //Run Everyday at 1am
        //use the following script
        //System.schedule('Business Licenses Open Renewal Job', '0 0 1 1/1 * ? *', new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicense WHERE DAY_ONLY(convertTimezone(PeriodEnd)) <= Renewal_Date__c AND Status != \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\'', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c}));
        //Database.executeBatch(new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicense WHERE DAY_ONLY(convertTimezone(PeriodEnd)) <= Renewal_Date__c AND Status != \''+AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c+'\'', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c}));

        //Business Licenses - Expiration Job
        //Run Everyday at 4am
        //use the following script
        //System.schedule('Business Licenses Expiration Job', '0 0 4 1/1 * ? *', new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicense WHERE Status != \''+AZSC_Constant__mdt.getInstance('LicenseStatusExpired').Value__c+'\'' AND PeriodEnd < TODAY', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('LicenseStatusExpired').Value__c}));
        //Database.executeBatch(new AZSC_ScheduleUpdateRecords('SELECT Id FROM BusinessLicense WHERE Status != \''+AZSC_Constant__mdt.getInstance('LicenseStatusExpired').Value__c+'\' AND PeriodEnd < TODAY', new Map<String,Object>{'Status' => AZSC_Constant__mdt.getInstance('LicenseStatusExpired').Value__c}));
    	
        Database.executeBatch(new AZSC_ScheduleUpdateRecords(query, paramKeytoValue));
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> records) {
        Map<Id,sObject> updateIdtoSObjs = new Map<Id,sObject>();
        for(sObject sObj : records) {
            for(String key : paramKeytoValue.keySet()) {
                sObj.put(key, paramKeytoValue.get(key));
            }
            updateIdtoSObjs.put(sObj.Id, sObj);
        }
        if(!updateIdtoSObjs.isEmpty())
            update updateIdtoSObjs.values();
    }
    global void finish(Database.BatchableContext BC) {}
}