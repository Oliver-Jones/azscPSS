/**
* @File Name : AZSC_LightningController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 13, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 13, 2025 |   | Initial Version
**/

public without sharing class AZSC_LightningController {
    @AuraEnabled
    public static Boolean createUser(Map<String,Object> params) {
        Id contactId, accountId;
        User adminUsr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRole.Name = 'System Admin' AND IsActive = TRUE LIMIT 1][0];
        Account accRec = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get((String)params.get('accessType')).getRecordTypeId(),
            OwnerId = adminUsr.Id
        );
        if((String)params.get('accessType') == 'Business_Account') {
            accRec.Type = 'Business';
            accRec.Name = (String)params.get('CompanyName');
        }
        else {
            accRec.Type = 'Individual';
            accRec.FirstName = (String)params.get('FirstName');
            accRec.LastName = (String)params.get('LastName');
            accRec.PersonEmail = (String)params.get('Email');
        }
        insert accRec;
        Contact conRec = new Contact();
        if((String)params.get('accessType') == 'Business_Account') {
            conRec.AccountId = accRec.Id;
            conRec.LastName = (String)params.get('LastName');
            conRec.FirstName = (String)params.get('FirstName');
            conRec.Email = (String)params.get('Email');
            insert conRec;
        }
        else {
            conRec = [SELECT Id,AccountId FROM Contact WHERE AccountId =: accRec.Id LIMIT 1][0];
        }
        String uniqueName = ((String)params.get('Email')).subStringBefore('@');
        User usrRec = new User(
            UserName = (String)params.get('Email') + '.azsc',
            FirstName = (String)params.get('FirstName'),
            LastName = (String)params.get('LastName'),
            Alias = uniqueName.length() > 8 ? uniqueName.left(4) + '' + uniqueName.right(4) : uniqueName,
            email = (String)params.get('Email'),
            ContactId = conRec.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'AZSC Portal User' Limit 1][0].Id,
            EmailEncodingKey = 'UTF-8',
            CommunityNickname = uniqueName.length() > 40 ? uniqueName.left(20) + '' + uniqueName.right(20) : uniqueName,
            TimeZoneSidKey = 'America/Yellowknife',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;       
        dmo.EmailHeader.triggerOtherEmail = true;
        dmo.EmailHeader.triggerAutoResponseEmail = true;       
        dmo.optAllOrNone = false;
        usrRec.setOptions(dmo);
        insert usrRec;
        return true;
    }
    
    @AuraEnabled
    public static List<User> checkDupicateUser(String email) {
        return [SELECT Id FROM User WHERE IsPortalEnabled = true AND Email =: email];
    }

    @AuraEnabled
    public static List<Map<String, Object>> fetchApplications(String userId) {
        List<User> users = [SELECT Id,AccountId,Account.Type,ContactId FROM User WHERE Id =: userId LIMIT 1];
        if(users[0].ContactId == null)
            return new List<Map<String, Object>>();
        List<Map<String, Object>> unifiedList = new List<Map<String, Object>>();
        List<Map<String, Object>> drafts = new List<Map<String, Object>>();
        List<Map<String, Object>> others = new List<Map<String, Object>>();
        Map<String,BusinessLicenseApplication> applications = new Map<String,BusinessLicenseApplication>();
        Map<String, List<BusinessLicenseApplication>> roleToSubApplications = new Map<String, List<BusinessLicenseApplication>>();
        List<Case_Relationship__c> participants = new List<Case_Relationship__c>();
        Map<String, List<Case_Relationship__c>> roleToParticipants = new Map<String, List<Case_Relationship__c>>();

        //Draft Applications
        Set<String> userIds = new Set<String>{userId, userId.left(15)};
        for(OmniscriptSavedSession oss : [SELECT Id,ABS_Application_Id__c,Application_Name__c,Application_Type__c,Business_Name__c,Business_Type__c,License_Id__c,Role__c,RelatedRecordIdentifier,StatusCategory,ResumeUrl,OmniScriptSubType,CreatedDate,LastModifiedDate,OmniScript.Name FROM OmniscriptSavedSession WHERE StatusCategory = 'In Progress' AND RelatedRecordIdentifier IN: userIds ORDER BY LastModifiedDate DESC]) {
            if(oss.ResumeUrl != Null && !oss.ResumeUrl.contains('/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=')) {
                String role = oss.OmniScriptSubType == 'AuthorizedEntityAppln' ? 'Authorized Person (Entity)' : (
                    oss.OmniScriptSubType == 'AuthorizedIndividualAppln' ? 'Authorized Person (Individual)' : (
                    oss.OmniScriptSubType == 'ComplianceLawyerAppln' ? 'Compliance Lawyer' : (
                    oss.OmniScriptSubType == 'DesignatedPrincipalAppln' ? 'Designated Principal' : 'Applicant'
                )));
                drafts.add(new Map<String, Object>{
                    'Identifier' => oss.Id,
                    'ApplnName' => oss.Application_Name__c,
                    /*'ApplnName' => (oss.OmniScriptSubType == 'InitialApplication' ? 'Alternative Business Structure License Application' : (
                        oss.OmniScriptSubType == 'DesignatedPrincipalAppln' ? 'ABS Designated Principal Sub Application' : (
                            oss.OmniScriptSubType == 'ComplianceLawyerAppln' ? 'ABS Compliance Lawyer Sub Application' : (
                                oss.OmniScriptSubType == 'AuthorizedIndividualAppln' ? 'ABS Authorized Individual Sub Application' : (
                                    oss.OmniScriptSubType == 'AuthorizedEntityAppln' ? 'ABS Authorized Entity Sub Application' : 'ABS License Renewal Application'
                                )
                            )
                        )
                    )),*/
                    'ApplnNum' => '',
                    'ApplnType' => oss.Application_Type__c,
                    //'ApplnType' => role == 'Applicant' ? (new System.PageReference(oss.ResumeURL).getParameters().get('c__applnType') ?? '') : 'Initial Licensure',
                    'Business' => oss.Business_Name__c,
                    'BusinessType' => oss.Business_Type__c,
                    //'BusinessType' => new System.PageReference(oss.ResumeURL).getParameters().get('c__applnCategory') ?? '',
                    'ApplnStatus' => 'Pending Submission',
                    'AppliedDate' => oss.CreatedDate,
                    'ApplnId' => '',
                    'IsResume' => true,
                    'ResumeURL' => oss.ResumeURL,
                    'CertId' => '',
                    'CertName' => '',
                    'IsPayLater' => false,
                    'Role' => role,
                    'Action' => 'Resume'
                });
            }
        }

        for(BusinessLicenseApplication appln : [
            SELECT Id,Status,Name,Account.Name,LicensePermitNameId,LicensePermitName.Name,AppliedDate,LicenseType.Name,Category,Business_License_Application__c,
            Business_License_Application__r.LicensePermitNameId,Business_License_Application__r.LicensePermitName.Name,Business_License_Application__r.RecordType.DeveloperName,
            Business_License_Application__r.RecordType.Name,RecordType.DeveloperName,RecordType.Name,Payment_Status__c,ApplicationType,Applicant_Applied_as__c FROM BusinessLicenseApplication 
            WHERE ApplicantId =: users[0].ContactId AND Status != 'New' ORDER BY CreatedDate DESC
        ]) {
            //Main Applications
            applications.put(appln.Id, appln);
            //Sub Applications
            if(appln.Business_License_Application__c != Null) {
                String key = appln.Business_License_Application__c + '' + appln.RecordType.DeveloperName;
                if(!roleToSubApplications.containsKey(key))
                    roleToSubApplications.put(key, new List<BusinessLicenseApplication>());
                roleToSubApplications.get(key).add(appln);
            }
        }

        //Participants Assignment for Sub Applications
        for(Case_Relationship__c participant : [
            SELECT Id,Role__c,Business_License_Application__c,Business_License_Application__r.Account.Name,Business_License_Application__r.Payment_Status__c,
            Business_License_Application__r.Status,Business_License_Application__r.Name,Business_License_Application__r.LicensePermitName.Name,
            Business_License_Application__r.AppliedDate,Business_License_Application__r.LicenseType.Name,Business_License_Application__r.Category,
            Business_License_Application__r.Applicant_Applied_as__c,Business_License_Application__r.ApplicationType,Business_License_Application__r.LicensePermitNameId,
            Business_License_Application__r.RecordType.Name,Business_License_Application__r.RecordType.DeveloperName FROM Case_Relationship__c 
            WHERE Person_Account__c =: users[0].AccountId AND Role__c != 'Statutory Agent' AND Do_not_Send_Sub_Application__c = false ORDER BY Business_License_Application__r.CreatedDate DESC
        ]) {
            participants.add(participant);
            String key = participant.Business_License_Application__c + '' + (
                participant.Role__c == 'Authorized Person (Entity)' ? 'ABS_Authorized_Entity_Sub_Application' : (
                participant.Role__c == 'Authorized Person (Individual)' ? 'ABS_Authorized_Individual_Sub_Application' : (
                participant.Role__c == 'Compliance Lawyer' ? 'ABS_Compliance_Lawyer_Sub_Application' : (
                participant.Role__c == 'Designated Principal' ? 'ABS_Designated_Principal_Sub_Application' : ''
            ))));
            if(!roleToParticipants.containsKey(key))
                roleToParticipants.put(key, new List<Case_Relationship__c>());
            roleToParticipants.get(key).add(participant);
        }

        //Unified List of Applications
        for(BusinessLicenseApplication appln : applications.values()) {
            others.add(new Map<String, Object>{
                'Identifier' => appln.Id,
                'ApplnName' => appln.RecordType.DeveloperName == 'ABS_Initial_Application' ? appln.LicenseType.Name : appln.RecordType.Name,
                'ApplnNum' => appln.Name,
                'ApplnType' => appln.ApplicationType,
                'Business' => appln.Account.Name,
                'BusinessType' => appln.Applicant_Applied_as__c,
                'ApplnStatus' => appln.Status,
                'AppliedDate' => appln.AppliedDate,
                'ApplnId' => appln.Id,
                'IsResume' => false,
                'IsMain' => true,
                'HasSubApplnDue' => false,
                'ResumeURL' => '',
                'CertId' => appln.LicensePermitNameId,
                'CertName' => appln.LicensePermitName?.Name,
                'IsPayLater' => appln.Status == 'Payment Pending' && appln.Payment_Status__c == 'Due',
                'Role' => '',
                'Action' => appln.Status == 'Payment Pending' && appln.Payment_Status__c == 'Due' ? 'Pay Now' : ''
            });
        }

        //Individual Applications
        for(IndividualApplication appln : [SELECT Id,Status,Name,Account.Name,LicensePermitNameId,LicensePermitName.Name,AppliedDate,LicenseType.Name,Category,
            RecordType.DeveloperName,RecordType.Name,Payment_Status__c,ApplicationType,Certification_Type__c FROM IndividualApplication 
            WHERE AccountId =: users[0].AccountId AND Status != 'New' ORDER BY CreatedDate DESC]) {
            others.add(new Map<String, Object>{
                'Identifier' => appln.Id,
                'ApplnName' => appln.RecordType.DeveloperName == 'ABS_Initial_Application' ? appln.LicenseType.Name : appln.RecordType.Name,
                'ApplnNum' => appln.Name,
                'ApplnType' => appln.ApplicationType,
                'Business' => appln.Account.Name,
                'BusinessType' => appln.Certification_Type__c,
                'ApplnStatus' => appln.Status,
                'AppliedDate' => appln.AppliedDate,
                'ApplnId' => appln.Id,
                'IsResume' => false,
                'IsMain' => true,
                'HasSubApplnDue' => false,
                'ResumeURL' => '',
                'CertId' => appln.LicensePermitNameId,
                'CertName' => appln.LicensePermitName?.Name,
                'IsPayLater' => appln.Status == 'Payment Pending' && appln.Payment_Status__c == 'Due',
                'Role' => '',
                'Action' => appln.Status == 'Payment Pending' && appln.Payment_Status__c == 'Due' ? 'Pay Now' : ''
            });
        }
        
        for(Case_Relationship__c participant : participants) {
            String key = participant.Business_License_Application__c + '' + (
                participant.Role__c == 'Authorized Person (Entity)' ? 'ABS_Authorized_Entity_Sub_Application' : (
                participant.Role__c == 'Authorized Person (Individual)' ? 'ABS_Authorized_Individual_Sub_Application' : (
                participant.Role__c == 'Compliance Lawyer' ? 'ABS_Compliance_Lawyer_Sub_Application' : (
                participant.Role__c == 'Designated Principal' ? 'ABS_Designated_Principal_Sub_Application' : ''
            ))));
            if(roleToParticipants.containsKey(key) && roleToSubApplications.containsKey(key)) {
                BusinessLicenseApplication subAppln = roleToSubApplications.get(key)[0];
                others.add(new Map<String, Object>{
                    'Identifier' => subAppln.Id,
                    'ApplnName' => subAppln.RecordType.DeveloperName == 'ABS_Initial_Application' ? subAppln.LicenseType.Name : subAppln.RecordType.Name,
                    'ApplnNum' => subAppln.Name,
                    'ApplnType' => subAppln.ApplicationType,
                    'Business' => subAppln.Account.Name,
                    'BusinessType' => subAppln.Applicant_Applied_as__c,
                    'ApplnStatus' => subAppln.Status,
                    'AppliedDate' => subAppln.AppliedDate,
                    'ApplnId' => subAppln.Id,
                    'IsResume' => false,
                    'HasSubApplnDue' => false,
                    'IsMain' => false,
                    'ResumeURL' => '',
                    'CertId' => subAppln.Business_License_Application__r.LicensePermitNameId,
                    'CertName' => subAppln.Business_License_Application__r.LicensePermitName?.Name,
                    'IsPayLater' => subAppln.Status == 'Payment Pending' && subAppln.Payment_Status__c == 'Due',
                    'Role' => participant.Role__c,
                    'Action' => subAppln.Status == 'Payment Pending' && subAppln.Payment_Status__c == 'Due' ? 'Pay Now' : ''
                });
            }
            else {
                others.add(new Map<String, Object>{
                    'Identifier' => participant.Id,
                    'ApplnName' => participant.Business_License_Application__r.RecordType.DeveloperName == 'ABS_Initial_Application' ? participant.Business_License_Application__r.LicenseType.Name : participant.Business_License_Application__r.RecordType.Name,
                    'ApplnNum' => participant.Business_License_Application__r.Name,
                    'ApplnType' => participant.Business_License_Application__r.ApplicationType,
                    'Business' => participant.Business_License_Application__r.Account.Name,
                    'BusinessType' => participant.Business_License_Application__r.Applicant_Applied_as__c,
                    'ApplnStatus' => participant.Business_License_Application__r.Status,
                    'AppliedDate' => participant.Business_License_Application__r.AppliedDate,
                    'ApplnId' => participant.Business_License_Application__r.Id,
                    'IsResume' => false,
                    'IsMain' => false,
                    'HasSubApplnDue' => participant.Business_License_Application__r.Status == 'Waiting for Sub Applications',
                    'ResumeURL' => '',
                    'CertId' => participant.Business_License_Application__r.LicensePermitNameId,
                    'CertName' => participant.Business_License_Application__r.LicensePermitName?.Name,
                    'IsPayLater' => participant.Business_License_Application__r.Status == 'Payment Pending' && participant.Business_License_Application__r.Payment_Status__c == 'Due',
                    'Role' => participant.Role__c,
                    'Action' => participant.Business_License_Application__r.Status == 'Waiting for Sub Applications' ? 'Launch Sub Application' : ''
                });
            }
        }

        if(!drafts.isEmpty()) unifiedList.addAll(drafts);
        if(!others.isEmpty()) unifiedList.addAll(others);
        return unifiedList;
    }

    /*@AuraEnabled
    public static List<OmniscriptSavedSession> fetchDraftApplications() {
        return [SELECT Id,RelatedRecordIdentifier,StatusCategory,ResumeUrl,OmniScriptSubType,CreatedDate,LastModifiedDate,OmniScript.Name FROM OmniscriptSavedSession WHERE StatusCategory = 'In Progress' AND RelatedRecordIdentifier =: UserInfo.getUserId() ORDER BY LastModifiedDate DESC];
    }*/

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getjBillingPaymentWebPage(String applnId) {
        Map<String,Object> output = new Map<String,Object>();
        List<RegulatoryTrxnFee> fees = [SELECT Id,Name,TotalFeeAmount FROM RegulatoryTrxnFee WHERE ParentRecordId =: applnId OR Person_Examination__c =: applnId ORDER BY CreatedDate DESC LIMIT 1];
        Jbilling_Merchant_Info__mdt jBillingMetadata =[
            SELECT GAO_Agency__c,ADO_END_Point__c,Batch_Agency__c,Merchant_ID_Prod__c, Merchant_ID_staging__c,Merchant_Name__c,Service_Prod__c,
            Service_staging__c,Board__c,DOC_agency__c,GaoTransactionType__c,GaoTransactionInstantce__c,Summary_Description__c,ADO_Test_Endpoint_URL__c,
            ADO_Return_Url__c,ADO_Test_Return_Url__c FROM Jbilling_Merchant_Info__mdt WHERE Label =: Constants.JBILLING_METADATA_LABEL LIMIT 1
        ];
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        String orderNumber, amount, merchantNumber, service, endpointURL, returnURL;
        List<RegulatoryTrxnFeeItem> feeItems = new List<RegulatoryTrxnFeeItem>();
        if(!fees.isEmpty()) {
            orderNumber = fees[0].Name.remove('FEE-');
            amount = String.valueOf(Integer.valueOf(fees[0].TotalFeeAmount*100));
            feeItems = [
                SELECT Id,FeeAmount,Fee_Type__c,Primary_GL_Account__c,Product_Description__c,Product_Revenue_Source__c,Function__c,RegulatoryTrxnFeeId 
                FROM RegulatoryTrxnFeeItem WHERE RegulatoryTrxnFeeId =: fees[0].Id
            ];
        }
        if(org.IsSandbox) {
            merchantNumber = jBillingMetadata.Merchant_ID_staging__c;//'SPA_TEST';
            service = jBillingMetadata.Service_staging__c;//'SPA_TEST_PAYMENT';
            endpointURL = jBillingMetadata.ADO_Test_Endpoint_URL__c;
            returnURL = jBillingMetadata.ADO_Test_Return_Url__c;
        } else {
            merchantNumber = jBillingMetadata.Merchant_ID_Prod__c; //'SPA';
            service = jBillingMetadata.Service_Prod__c;//'SPA_PAYMENT';
            endpointURL = jBillingMetadata.ADO_END_Point__c;
            returnURL = jBillingMetadata.ADO_Return_Url__c;
        }
        AZSC_JBillingPaymentService.JBillingPayload payload = new AZSC_JBillingPaymentService.JBillingPayload();
        payload.endPointURL = endpointURL;
        payload.gAOTransactionType = jBillingMetadata.GaoTransactionType__c ?? '';
        payload.gAOTransactionInstance = jBillingMetadata.GaoTransactionInstantce__c ?? '';
        payload.merchantName = jBillingMetadata.Merchant_Name__c ?? '';
        payload.merchantNumber = merchantNumber;
        payload.orderNumber = orderNumber;
        payload.service = service;
        payload.gAOAgency = jBillingMetadata.GAO_Agency__c ?? '';
        payload.dOCAgency = jBillingMetadata.DOC_agency__c ?? '';
        payload.amount = amount;
        payload.paymentMethod = 'ALL';
        payload.returnURL = returnURL;
        payload.summaryDescription = jBillingMetadata.Summary_Description__c ?? '';
        payload.lineItems = new List<AZSC_JBillingPaymentService.LineItem>();
        for(RegulatoryTrxnFeeItem feeItem : feeItems) {
            AZSC_JBillingPaymentService.LineItem lineItem = new AZSC_JBillingPaymentService.LineItem();
            lineItem.gAOProductCode = feeItem.Primary_GL_Account__c ?? '';
            lineItem.gAOAgency = jBillingMetadata.GAO_Agency__c ?? '';
            lineItem.function = feeItem.Function__c ?? '';
            lineItem.revenueSource = feeItem.Product_Revenue_Source__c ?? '';
            lineItem.departmentRevenueSource = feeItem.Product_Revenue_Source__c ?? '';
            lineItem.accountingTemplate = '';
            lineItem.gAODescription = feeItem.Product_Description__c ?? '';
            lineItem.amount = String.valueOf(Integer.valueOf((feeItem.FeeAmount ?? 0)*100));
            lineItem.quantity = '1';
            payload.lineItems.add(lineItem);
        }
        output = AZSC_JBillingPaymentService.getOrderURL(payload);
        updateFeeWithPayload(fees[0].Id, ''+payload);
        if((Boolean)output.get('success') == true) {
            String paymentURL = ((String)output.get('paymentURL')).remove('url=');
            output.put('paymentURL', paymentURL);
            String errorCode = paymentURL.substring(paymentURL.indexOf('error')+6,paymentURL.indexOf('error')+7);
            if(errorCode == '1' || errorCode == '2' || errorCode == '3' )
                output.put('success', false);
        }
        return output;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> generateServerSidePDF(String recordId, String contentId, String docTitle) {
        List<DocumentTemplate> templates = [SELECT Id FROM DocumentTemplate WHERE Name =: contentId AND IsActive = true];
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        input.put('objectId', recordId);
        input.put('templateId', !templates.isEmpty() ? templates[0].Id : contentId);
        input.put('title', docTitle);
        input.put('outputFileFormat', 'pdf');
        input.put('contextId', recordId);
        input.put('keepIntermediate', true);
        input.put('returnAsPdf', true);
        Omnistudio.DocumentServiceGateway ctrl = new Omnistudio.DocumentServiceGateway();
        ctrl.invokeMethod('generateDocument', input, output, options);
        return output;
    }

    @AuraEnabled(cacheable=false)
    public static void UpdateApplnStatusToPaymentPending(String recordId, String draftId) {
        update new BusinessLicenseApplication(Id = recordId, Status = 'Payment Pending', Payment_Status__c = 'Due');
        if(draftId != Null)
            update new OmniscriptSavedSession(Id = draftId, StatusCategory = 'Completed');
    }

    @future
    public static void updateFeeWithPayload(Id feeId, String payload) {
        update new RegulatoryTrxnFee(Id = feeId, Request_XML__c = payload);
    }
}