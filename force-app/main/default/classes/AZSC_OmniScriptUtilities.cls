global without sharing class AZSC_OmniScriptUtilities implements Callable {
    public Object call(String action, Map<String, Object> args) {
        if(action == 'createUser') {
            createUser(args);
        }
        if(action == 'submitDocumentChecklistItems') {
            submitDocumentChecklistItems(args);
        }
        if(action == 'insertRegTrxnFeeItems') {
            insertRegTrxnFeeItems(args);
        }
        if(action == 'getRegTrxnFeeItems') {
            getRegTrxnFeeItems(args);
        }
        if(action == 'UpdateApplnStatusToPaymentPending') {
            updateApplnStatusToPaymentPending(args);
        }
        if(action == 'UpdateApplnStatusToSubmitted') {
            updateApplnStatusToSubmitted(args);
        }
        if(action == 'insertAuthorizedPersons') {
            insertAuthorizedPersons(args);
        }
        if(action == 'upsertParticipant') {
            upsertParticipant(args);
        }
        if(action == 'checkSubApplicationDue') {
            checkSubApplicationDue(args);
        }
        if(action == 'updateDraftApplication') {
            updateDraftApplication(args);
        }
        if(action == 'DeleteExistingRecords') {
            deleteExistingRecords(args);
        }
        if(action == 'AutoAddRemoveAuthPerson') {
            autoAddRemoveAuthPerson(args);
        }
        if(action == 'fetchApplications') {
            fetchApplications(args);
        }
        if(action == 'fetchLicenses') {
            fetchLicenses(args);
        }
        if(action == 'copyPreviousAuthPersons') {
            copyPreviousAuthPersons(args);
        }
        if(action == 'SaveCertifiedStatesInfo') {
            SaveCertifiedStatesInfo(args);
        }
        if(action == 'getjBillingPaymentWebPage') {
            getjBillingPaymentWebPage(args);
        }
        return null;
    }
    
    public static void SaveCertifiedStatesInfo(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String ApplnId = (String) input.get('ApplicationId');
        List<Object> rawObjects = (List<Object>) input.get('CertifiedStateData');
        List<Application_Information__c> applnInfoList = new List<Application_Information__c>();
        Id recordTypeId = Schema.SObjectType.Application_Information__c.getRecordTypeInfosByDeveloperName().get('Certified_States').getRecordTypeId();
        for(Object tempObj : rawObjects) {
            Map<String, Object> rawObject = (Map<String, Object>)tempObj;
            Application_Information__c applnInfo = new Application_Information__c();
            applnInfo.IndApplication__c = ApplnId;
            applnInfo.RecordTypeId = recordTypeId;
            applnInfo.Certified_Address__StateCode__s = (String)rawObject.get('CertifiedState');
            applnInfo.Certification_Date__c = Date.valueOf((String)rawObject.get('CertificationDate'));
            applnInfo.Expiration_Date__c = Date.valueOf((String)rawObject.get('ExpirationDate'));
            applnInfo.Certifying_Entity_Name__c = (String)rawObject.get('EntityName');
            applnInfo.Certified_Address__Street__s = (String)rawObject.get('EntityAddress');
            applnInfo.Phone_Number__c = (String)rawObject.get('EntityPhone');
            applnInfo.Email_Address__c = (String)rawObject.get('EntityEmail');
            applnInfoList.add(applnInfo);
        }
        Insert applnInfoList;
    }

    public static void submitDocumentChecklistItems(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, DocumentChecklistItem> chklists = new Map<String, DocumentChecklistItem>();
        Map<String, ContentDocumentLink> cntDocs = new Map<String, ContentDocumentLink>();
        Map<String, Object> blocks = new Map<String, Object>();
        String parentRecId = (String) input.get('ParentRecordId');
        if(String.valueOf(input.get('DocumentUploads')) != null && String.valueOf(input.get('DocumentUploads')) != '') {
            blocks = (Map<String, Object>) input.get('DocumentUploads');
            System.debug('blocks>>>' + blocks);
        }
        List<Object> blockValues = (List<Object>) blocks.values();
        List<Map<String, Object>> finalJsonList = new List<Map<String, Object>>();
        List<Map<String, Object>> tempJsonList = new List<Map<String, Object>>();
        for(Object blockObj: blockValues) {
            if(blockObj instanceof Map<String, Object> && blockObj != null) {
                Map<String, Object> blockValue = (Map<String, Object>) blockObj;
                String fileKey = '', docNameKey = '';
                for(String key: blockValue.keySet()) {
                        System.debug('key>>>' + key);
                    if(key.containsIgnoreCase('File')) {
                        fileKey = key;
                    }
                    if(key.containsIgnoreCase('Name')) {
                        docNameKey = key;
                    }
                    if(fileKey<> '' && docNameKey<> '') {
                        Map<String, Object> modifyMap1 = new map<String, Object>();
                        System.debug('blockValue>>>' + blockValue);
                        System.debug('docNameKey>>>' + docNameKey);
                        System.debug('fileKey>>>' + fileKey);
                        modifyMap1.put('Name', blockValue.get(docNameKey));
                        modifyMap1.put('Data', (List<Object>) blockValue.get(fileKey));
                        tempJsonList.add(modifyMap1);
                    }
                }
            }
        }
        for(Map<String, Object> objMap: tempJsonList) {
            Integer i = 1;
            for(Object obj2: (List<Object>) objMap.get('Data')) {
                Map<String, Object> objMap1 = (Map<String, Object>) obj2;
                finalJsonList.add(new Map<String, Object> {
                    'Name' => objMap.get('Name') + '_' + i,
                    'Data' => objMap1.get('data')
                });
                i++;
            }
        }
        for(Map<String, Object> objMap: finalJsonList) {
            if(objMap.containsKey('Name')) 
                chklists.put((String) objMap.get('Name'), new DocumentChecklistItem(Name = (String) objMap.get('Name'), ParentRecordId = parentRecId));
        }
        if(!chklists.isEmpty()) {
            insert chklists.values();
            for(Map<String, Object> objMap: finalJsonList) {
                if(objMap.containsKey('Data') && objMap.containsKey('Name') && chklists.containsKey((String) objMap.get('Name'))) 
                    cntDocs.put((String) objMap.get('Name'), new ContentDocumentLink(
                        Visibility = 'AllUsers', LinkedEntityId = chklists.get((String) objMap.get('Name')).Id, 
                        ContentDocumentId = (String) objMap.get('Data')
                    ));
            }
            if(!Test.isRunningTest() && !cntDocs.isEmpty()) insert cntDocs.values();
        } 
    }

    public static void insertRegTrxnFeeItems(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String parentRecId = (String) input.get('ApplicationId');
        String accountRecId = (String) input.get('AccountId');
        Boolean isPortalEnabled = input.containsKey('IsPortalEnabled') ? (Boolean) input.get('IsPortalEnabled') : false;
        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(AccountId = accountRecId, Comments = (String) input.get('ApplicationName') + ' - ' + (String) input.get('FeeType') + ' - ' + (String) input.get('ApplnCategory'), ParentRecordId = parentRecId, Status = 'Due', From_Portal__c = isPortalEnabled, Partial_Fee__c = input.containsKey('IsPartialFee') ? (Boolean) input.get('IsPartialFee') : false);
        if(input.containsKey('appType') && (String) input.get('appType') == 'ExamRegistration') {
            fee.ParentRecordId = Null;
            fee.Person_Examination__c = parentRecId;
        }
        insert fee;
        List<Object> rawObjects = (List<Object>) input.get('FeeData');
        List<RegulatoryTrxnFeeItem> fees = new List<RegulatoryTrxnFeeItem>();
        for(Object tempObj : rawObjects) {
            Map<String, Object> rawObject = (Map<String, Object>)tempObj;
            fees.add(new RegulatoryTrxnFeeItem(
                Name = (String) rawObject.get('ProductDesc'),
                FeeAmount = Decimal.valueOf((String) rawObject.get('Fee')),
                RegulatoryTrxnFeeId = fee.Id,
                Function__c = (String) rawObject.get('Function'),
                Primary_GL_Account__c = (String) rawObject.get('ProductCode'),
                Product_Revenue_Source__c = (String) rawObject.get('RevenueSource'),
                Product_Description__c = (String) rawObject.get('ProductDesc'),
                CalculationInfo = (String) input.get('appType')
            ));
        }
        if(!fees.isEmpty())
            insert fees;
        output.put('FeeId', fee.Id);
    }

    public static void getRegTrxnFeeItems(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String parentRecId = (String) input.get('regTrxnFeeId');
        Decimal total = 0;
        List<RegulatoryTrxnFeeItem> feeItems = [SELECT Id, Name, Comments, FeeAmount, Fee_Type__c FROM RegulatoryTrxnFeeItem WHERE RegulatoryTrxnFeeId =: parentRecId];
        for(RegulatoryTrxnFeeItem feeItem : feeItems) {
            total += feeItem.FeeAmount;
        }
        output.put('FeeItemList', JSON.serialize(feeItems));
        output.put('FeeTotal', total);
    }

    public static void updateApplnStatusToPaymentPending(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String parentRecId = (String) input.get('recordId');
        if(parentRecId != Null) {
            update new BusinessLicenseApplication(Id = parentRecId, Status = 'Payment Pending', Payment_Status__c = 'Due');
        }
    }

    public static void updateApplnStatusToSubmitted(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String indApplnId = input.containsKey('IndApplnId') ? (String) input.get('IndApplnId') : '';
        String busApplnId = input.containsKey('BusApplnId') ? (String) input.get('BusApplnId') : '';
        String indExamId = input.containsKey('IndExamId') ? (String) input.get('IndExamId') : '';
        if(indApplnId != '') {
            List<IndividualApplication> applns = [SELECT Id,Name,Payment_Status__c,LicensePermitNameId FROM IndividualApplication WHERE Id =: indApplnId];
            if(!applns.isEmpty()) {
                update new IndividualApplication(Id = indApplnId, Status = 'Submitted');
                output.put('ApplnNumber', applns[0].Name);
                if(applns[0].Payment_Status__c == 'Partial Payment Pending' && applns[0].LicensePermitNameId != Null) {
                    update new BusinessLicense(Id = applns[0].LicensePermitNameId, VerificationStatus = 'Partial Payment Pending');
                }
                else {
                    if(applns[0].LicensePermitNameId != Null) {
                        update new BusinessLicense(Id = applns[0].LicensePermitNameId, VerificationStatus = 'Authorized');
                    }
                }
            }
        }
        else if(busApplnId != '') {
            List<BusinessLicenseApplication> applns = [SELECT Id,Name,RecordType.DeveloperName,Business_License_Application__c,Payment_Status__c,LicensePermitNameId FROM BusinessLicenseApplication WHERE Id =: busApplnId];
            if(!applns.isEmpty()) {
                if(applns[0].RecordType.DeveloperName == 'ABS_Application') {
                    if(applns[0].Business_License_Application__c != Null) {
                        Map<String, Case_RelationShip__c> applicants = new Map<String, Case_RelationShip__c>();
                        for(Case_RelationShip__c applicant : [SELECT Id,Role__c,Person_Account__c FROM Case_RelationShip__c WHERE Role__c != 'Statutory Agent' AND Do_not_Send_Sub_Application__c = false AND Business_License_Application__c =: applns[0].Business_License_Application__c]) {
                            String role = applicant.Role__c == 'Authorized Person (Entity)' ? 'ABS_Authorized_Entity_Sub_Application' : (
                                applicant.Role__c == 'Authorized Person (Individual)' ? 'ABS_Authorized_Individual_Sub_Application' : (
                                    applicant.Role__c == 'Compliance Lawyer' ? 'ABS_Compliance_Lawyer_Sub_Application' : (
                                        applicant.Role__c == 'Designated Principal' ? 'ABS_Designated_Principal_Sub_Application' : ''
                                    )
                                )
                            );
                            applicants.put(role+'_'+applicant.Person_Account__c, applicant);
                        }
                        Map<String, BusinessLicenseApplication> applications = new Map<String, BusinessLicenseApplication>();
                        for(BusinessLicenseApplication application : [SELECT Id,RecordType.DeveloperName,Applicant.AccountId FROM BusinessLicenseApplication WHERE Business_License_Application__c =: applns[0].Business_License_Application__c]) {
                            applications.put(application.RecordType.DeveloperName+'_'+application.Applicant.AccountId, application);
                        }
                        update new BusinessLicenseApplication(Id = busApplnId, Status = applicants.size() == applications.size() ? 'Submitted' : 'Waiting for Sub Applications');
                    }
                    else {
                        update new BusinessLicenseApplication(Id = busApplnId, Status = 'Waiting for Sub Applications');
                    }
                }
                else {
                    update new BusinessLicenseApplication(Id = busApplnId, Status = 'Submitted');
                    if(applns[0].Payment_Status__c == 'Partial Payment Pending' && applns[0].LicensePermitNameId != Null) {
                        update new BusinessLicense(Id = applns[0].LicensePermitNameId, VerificationStatus = 'Partial Payment Pending');
                    }
                    else {
                        if(applns[0].LicensePermitNameId != Null) {
                            update new BusinessLicense(Id = applns[0].LicensePermitNameId, VerificationStatus = 'Authorized');
                        }
                    }
                }
                output.put('ApplnNumber', applns[0].Name);
            }
        }
        else if(indExamId != '') {
            List<PersonExamination> applns = [SELECT Id,Name,Exam_Slot__c FROM PersonExamination WHERE Id =: indExamId];
            if(!applns.isEmpty()) {
                update new PersonExamination(Id = indExamId, Status__c = 'Scheduled');
                output.put('ApplnNumber', applns[0].Name);
                output.put('ExamSlot', applns[0].Exam_Slot__c);
            }
        }
    }

    public static void insertAuthorizedPersons(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> blocks = new Map<String, Object>();
        if(String.valueOf(input.get('AuthorizedPersonInformation')) != null && String.valueOf(input.get('AuthorizedPersonInformation')) != '') {
            blocks = (Map<String, Object>) input.get('AuthorizedPersonInformation');
        }
        if(!blocks.isEmpty()) {
            List<Map<String,Object>> blockValues = new List<Map<String,Object>>();
            if(blocks.get('AuthorizedPersonBlock') instanceof Map<String, Object>)
                blockValues.add((Map<String,Object>) blocks.get('AuthorizedPersonBlock'));
            else
                blockValues = (List<Map<String,Object>>) blocks.get('AuthorizedPersonBlock');
            List<Account> accs = new List<Account>();
            Map<String,Map<String, Object>> accToData = new Map<String,Map<String, Object>>();
            List<Contact> cons = new List<Contact>();
            User adminUsr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRole.Name = 'System Admin' AND IsActive = TRUE LIMIT 1][0];
            Map<String,Case_Relationship__c> accIdToParticipant = new Map<String,Case_Relationship__c>();
            for(Object blockObj : blockValues) {
                if(blockObj instanceof Map<String, Object> && blockObj != null) {
                    Map<String, Object> blockValue = (Map<String, Object>) blockObj;
                    Map<String, Object> response = blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual'
                        ? doPersonAccountMatch(new Map<String, Object> {
                            'FirstName' => blockValue.containsKey('AuthorizedPersonFirstName') ? blockValue.get('AuthorizedPersonFirstName') : '',
                            'LastName' => blockValue.containsKey('AuthorizedPersonLastName') ? blockValue.get('AuthorizedPersonLastName') : '',
                            'Email' => blockValue.containsKey('AuthorizedPersonEmail') ? blockValue.get('AuthorizedPersonEmail') : '',
                            'Phone' => blockValue.containsKey('AuthorizedPersonTelephone') ? blockValue.get('AuthorizedPersonTelephone') : ''
                        }) : doBusinessAccountMatch(new Map<String, Object> {
                            'Name' => blockValue.containsKey('AuthorizedPersonLegalName') ? blockValue.get('AuthorizedPersonLegalName') : '',
                            'Email' => blockValue.containsKey('AuthorizedPersonEmail') ? blockValue.get('AuthorizedPersonEmail') : '',
                            'Phone' => blockValue.containsKey('AuthorizedPersonPhone') ? blockValue.get('AuthorizedPersonPhone') : ''
                    });
                    if(!response.containsKey('AccountId')) {
                        Account acc = new Account(
                            OwnerId = adminUsr.Id,
                            Type = blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual' ? 'Authorized Person' : 'Authorized Entity',
                            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual' ? 'PersonAccount' : 'Business_Account').getRecordTypeId(),
                            Phone = blockValue.containsKey('AuthorizedPersonTelephone') ? ''+blockValue.get('AuthorizedPersonTelephone') : ''
                        );
                        if(blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual') {
                            acc.FirstName = blockValue.containsKey('AuthorizedPersonFirstName') ? ''+blockValue.get('AuthorizedPersonFirstName') : '';
                            acc.LastName = blockValue.containsKey('AuthorizedPersonLastName') ? ''+blockValue.get('AuthorizedPersonLastName') : '';
                            acc.MiddleName = blockValue.containsKey('AuthorizedPersonMiddleName') && blockValue.get('AuthorizedPersonMiddleName') != null ? ''+blockValue.get('AuthorizedPersonMiddleName') : '';
                            acc.PersonEmail = blockValue.containsKey('AuthorizedPersonEmail') ? ''+blockValue.get('AuthorizedPersonEmail') : '';
                            accToData.put(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail, blockValue);
                        }
                        else {
                            acc.Name = blockValue.containsKey('AuthorizedPersonLegalName') ? ''+blockValue.get('AuthorizedPersonLegalName') : '';
                            acc.POC_Email__c = blockValue.containsKey('AuthorizedPersonEmail') ? ''+blockValue.get('AuthorizedPersonEmail') : '';
                            accToData.put(acc.Name+''+acc.POC_Email__c, blockValue);
                        }
                        accs.add(acc);
                    }
                    else {
                        Case_Relationship__c participant = new Case_Relationship__c(
                            Business_License_Application__c = input.containsKey('ApplicationId') ? ''+input.get('ApplicationId') : Null,
                            Person_Account__c = ''+response.get('AccountId'),
                            Email__c = blockValue.containsKey('AuthorizedPersonEmail') ? ''+blockValue.get('AuthorizedPersonEmail') : '',
                            Phone__c = blockValue.containsKey('AuthorizedPersonTelephone') ? ''+blockValue.get('AuthorizedPersonTelephone') : '',
                            Status__c = 'Active',
                            Role__c = (blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual' ? 'Authorized Person (Individual)' : 'Authorized Person (Entity)'),
                            Business_License__c = input.containsKey('LicenseId') && input.get('LicenseId')  != ''? ''+input.get('LicenseId') : Null,
                            Start_Date__c = System.today()
                        );
                        if(String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual' && blockValue.containsKey('DoNotCreateUser') && (Boolean)blockValue.get('DoNotCreateUser') == true) {
                            participant.Do_not_Send_Sub_Application__c = true;
                            if(input.containsKey('HasEconomicInterest') && (Boolean)input.get('HasEconomicInterest') == true)
                                participant.Has_Economic_Interest__c = true;
                            if(input.containsKey('HasRightToDecisionMaking') && (Boolean)input.get('HasRightToDecisionMaking') == true)
                                participant.Has_Right_to_Decision_Making__c = true;
                            if(input.containsKey('Ownership') && input.get('Ownership') != null)
                                participant.Ownership__c = (Decimal)input.get('Ownership');
                        }
                        if(blockValue.containsKey('AuthorizedPersonType') && String.valueOf(blockValue.get('AuthorizedPersonType')) == 'Individual') {
                            participant.First_Name__c = blockValue.containsKey('AuthorizedPersonFirstName') ? ''+blockValue.get('AuthorizedPersonFirstName') : '';
                            participant.Middle_Name__c = blockValue.containsKey('AuthorizedPersonMiddleName') && blockValue.get('AuthorizedPersonMiddleName') != null ? ''+blockValue.get('AuthorizedPersonMiddleName') : '';
                            participant.Last_Name__c = blockValue.containsKey('AuthorizedPersonLastName') ? ''+blockValue.get('AuthorizedPersonLastName') : '';
                        }
                        else 
                            participant.Business_Name__c = blockValue.containsKey('AuthorizedPersonLegalName') ? ''+blockValue.get('AuthorizedPersonLegalName') : '';
                        accIdToParticipant.put(''+response.get('AccountId'), participant);
                    }
                }
            }
            if(!accs.isEmpty()) {
                insert accs;
                for(Account acc : accs) {
                    if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId()) {
                        cons.add(new Contact(
                            AccountId = acc.Id,
                            FirstName = accToData.get(acc.Name+''+acc.POC_Email__c).containsKey('AuthorizedPersonPOCFirstName') ? ''+accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonPOCFirstName') : '',
                            LastName = accToData.get(acc.Name+''+acc.POC_Email__c).containsKey('AuthorizedPersonPOCLastName') ? ''+accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonPOCLastName') : '',
                            Email = accToData.get(acc.Name+''+acc.POC_Email__c).containsKey('AuthorizedPersonPOCEmail') && accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonPOCEmail') != null && accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonPOCEmail') != 'null' ? ''+accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonPOCEmail') : '',
                            Phone = acc.Phone
                        ));
                    }
                    Case_Relationship__c participant = new Case_Relationship__c(
                        Business_License_Application__c = input.containsKey('ApplicationId') ? ''+input.get('ApplicationId') : Null,
                        Person_Account__c = acc.Id,
                        Status__c = 'Active',
                        Role__c = acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId() ? 'Authorized Person (Individual)' : 'Authorized Person (Entity)',
                        Business_License__c = input.containsKey('LicenseId') && input.get('LicenseId') != '' ? ''+input.get('LicenseId') : Null,
                        Start_Date__c = System.today()
                    );
                    if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId() && accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).containsKey('DoNotCreateUser') && (Boolean)(accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).get('DoNotCreateUser')) == true) {
                        participant.Do_not_Send_Sub_Application__c = true;
                        if(input.containsKey('HasEconomicInterest') && (Boolean)input.get('HasEconomicInterest') == true)
                            participant.Has_Economic_Interest__c = true;
                        if(input.containsKey('HasRightToDecisionMaking') && (Boolean)input.get('HasRightToDecisionMaking') == true)
                            participant.Has_Right_to_Decision_Making__c = true;
                        if(input.containsKey('Ownership') && input.get('Ownership') != null)
                            participant.Ownership__c = (Decimal)input.get('Ownership');
                    }
                    if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()) {
                        participant.First_Name__c = accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).containsKey('AuthorizedPersonFirstName') ? ''+accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).get('AuthorizedPersonFirstName') : '';
                        participant.Middle_Name__c = accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).containsKey('AuthorizedPersonMiddleName') && accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).get('AuthorizedPersonMiddleName') != null ? ''+accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).get('AuthorizedPersonMiddleName') : '';
                        participant.Last_Name__c = accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).containsKey('AuthorizedPersonLastName') ? ''+accToData.get(acc.FirstName+''+acc.MiddleName+''+acc.LastName+''+acc.PersonEmail).get('AuthorizedPersonLastName') : '';
                    }
                    else 
                        participant.Business_Name__c = accToData.get(acc.Name+''+acc.POC_Email__c).containsKey('AuthorizedPersonLegalName') ? ''+accToData.get(acc.Name+''+acc.POC_Email__c).get('AuthorizedPersonLegalName') : '';
                    accIdToParticipant.put(acc.Id, participant);
                }
            }
            if(!accIdToParticipant.isEmpty()) {
                insert accIdToParticipant.values();
            }
            if(!cons.isEmpty()) {
                insert cons;
            }
        }
    }

    public static void upsertParticipant(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Case_Relationship__c participant = new Case_Relationship__c(
            Business_License_Application__c = input.containsKey('ApplicationId') ? ''+input.get('ApplicationId') : null,
            Status__c = 'Active',
            Role__c = input.containsKey('ParticipantRole') ? ''+input.get('ParticipantRole') : '',
            //Case__c = input.containsKey('CaseId') ? ''+input.get('CaseId') : null,
            Start_Date__c = System.today()
        );
        if(input.containsKey('HasEconomicInterest') && (Boolean)input.get('HasEconomicInterest') == true)
            participant.Has_Economic_Interest__c = true;
        if(input.containsKey('HasRightToDecisionMaking') && (Boolean)input.get('HasRightToDecisionMaking') == true)
            participant.Has_Right_to_Decision_Making__c = true;
        if(input.containsKey('Ownership') && input.get('Ownership') != null)
            participant.Ownership__c = (Decimal)input.get('Ownership');
        User adminUsr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRole.Name = 'System Admin' AND IsActive = TRUE LIMIT 1][0];
        Map<String, Object> response = String.valueOf(input.get('ParticipantType')) == 'Individual' ? doPersonAccountMatch(input) : doBusinessAccountMatch(input);
        participant.Business_Name__c = input.containsKey('Name') ? ''+input.get('Name') : '';
        participant.Social_Security_Number__c = input.containsKey('SSN') ? ''+input.get('SSN') : '';
        participant.First_Name__c = input.containsKey('FirstName') ? ''+input.get('FirstName') : '';
        participant.Middle_Name__c = input.containsKey('MiddleName') && input.get('MiddleName') != null && input.get('MiddleName') != 'null' ? ''+input.get('MiddleName') : '';
        participant.Last_Name__c = input.containsKey('LastName') ? ''+input.get('LastName') : '';
        participant.Email__c = input.containsKey('Email') ? ''+input.get('Email') : '';
        participant.Phone__c = input.containsKey('Phone') ? ''+input.get('Phone') : '';
        participant.Date_of_Birth__c = input.containsKey('DOB') && input.get('DOB') != null && input.get('DOB') != '' ? Date.valueOf(''+input.get('DOB')) : null;
        participant.Address__Street__s = input.containsKey('Street') ? ''+input.get('Street') : '';
        participant.Address__StateCode__s = input.containsKey('State') ? ''+input.get('State') : '';
        participant.Address__CountryCode__s = input.containsKey('Country') ? ''+input.get('Country') : '';
        participant.Address__City__s = input.containsKey('City') ? ''+input.get('City') : '';
        participant.Address__PostalCode__s = input.containsKey('Zip') ? ''+input.get('Zip') : '';
        participant.Home_Address__Street__s = input.containsKey('HomeStreet') ? ''+input.get('HomeStreet') : '';
        participant.Home_Address__StateCode__s = input.containsKey('HomeState') ? ''+input.get('HomeState') : '';
        participant.Home_Address__CountryCode__s = input.containsKey('HomeCountry') ? ''+input.get('HomeCountry') : '';
        participant.Home_Address__City__s = input.containsKey('HomeCity') ? ''+input.get('HomeCity') : '';
        participant.Home_Address__PostalCode__s = input.containsKey('HomeZip') ? ''+input.get('HomeZip') : '';
        if(response.containsKey('AccountId')) {
            output.put('AccountId', ''+response.get('AccountId'));
            output.put('ContactId', ''+response.get('ContactId'));
            participant.Person_Account__c = ''+response.get('AccountId');
        }
        else {
            Account acc = new Account(
                OwnerId = adminUsr.Id,
                Type = input.containsKey('ParticipantRole') ? ''+input.get('ParticipantRole') : '',
                Phone = input.containsKey('Phone') ? ''+input.get('Phone') : '',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(input.get('ParticipantType')) == 'Individual' ? 'PersonAccount' : 'Business_Account').getRecordTypeId(),
                BillingStreet = input.containsKey('Street') ? ''+input.get('Street') : '',
                BillingStateCode = input.containsKey('State') ? ''+input.get('State') : '',
                BillingCountryCode = input.containsKey('Country') ? ''+input.get('Country') : '',
                BillingCity = input.containsKey('City') ? ''+input.get('City') : '',
                BillingPostalCode = input.containsKey('Zip') ? ''+input.get('Zip') : ''
            );
            if(String.valueOf(input.get('ParticipantType')) == 'Individual') {
                acc.FirstName = input.containsKey('FirstName') ? ''+input.get('FirstName') : '';
                acc.LastName = input.containsKey('LastName') ? ''+input.get('LastName') : '';
                acc.MiddleName = input.containsKey('MiddleName') && input.get('MiddleName') != null && input.get('MiddleName') != 'null' ? ''+input.get('MiddleName') : '';
                acc.PersonEmail = input.containsKey('Email') ? ''+input.get('Email') : '';
                acc.PersonBirthDate = input.containsKey('DOB') && input.get('DOB') != null && input.get('DOB') != '' ? Date.valueOf(''+input.get('DOB')) : null;
                acc.Social_Security_Number__pc = input.containsKey('SSN') ? ''+input.get('SSN') : '';
                acc.SSN__pc = input.containsKey('SSN') ? ''+input.get('SSN') : '';
                acc.PersonMailingStreet = input.containsKey('HomeStreet') ? ''+input.get('HomeStreet') : '';
                acc.PersonMailingStateCode = input.containsKey('HomeState') ? ''+input.get('HomeState') : '';
                acc.PersonMailingCountryCode = input.containsKey('HomeCountry') ? ''+input.get('HomeCountry') : '';
                acc.PersonMailingCity = input.containsKey('HomeCity') ? ''+input.get('HomeCity') : '';
                acc.PersonMailingPostalCode = input.containsKey('HomeZip') ? ''+input.get('HomeZip') : '';
            }
            else {
                acc.Name = input.containsKey('Name') ? ''+input.get('Name') : '';
                acc.POC_Email__c = input.containsKey('Email') ? ''+input.get('Email') : '';
            }
            insert acc;
            output.put('AccountId', acc.Id);
            participant.Person_Account__c = acc.Id;
            if(String.valueOf(input.get('ParticipantType')) == 'Individual') {
                output.put('ContactId', [SELECT Id,PersonContactId FROM Account WHERE Id =: acc.Id LIMIT 1][0].PersonContactId);
            }
            else {
                Contact con = new Contact(
                    OwnerId = adminUsr.Id,
                    AccountId = acc.Id,
                    FirstName = input.containsKey('POCFirstName') ? ''+input.get('POCFirstName') : '',
                    LastName = input.containsKey('POCLastName') ? ''+input.get('POCLastName') : '',
                    Email = input.containsKey('POCEmail') ? ''+input.get('POCEmail') : '',
                    Phone = input.containsKey('Phone') ? ''+input.get('Phone') : '',
                    BirthDate = input.containsKey('DOB') && input.get('DOB') != null && input.get('DOB') != '' ? Date.valueOf(''+input.get('DOB')) : null,
                    Social_Security_Number__c = input.containsKey('SSN') ? ''+input.get('SSN') : '',
                    SSN__c = input.containsKey('SSN') ? ''+input.get('SSN') : ''
                );
                insert con;
                output.put('ContactId', con.Id);
            }
        }
        insert participant;
        output.put('ParticipantId', participant.Id);
    }

    public static void updateDraftApplication(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        if(input.containsKey('draftId') && ''+input.get('draftId') != '') {
            update new OmniscriptSavedSession(Id = ''+input.get('draftId'), StatusCategory = 'Completed');
        }
    }
    
    public static void deleteExistingRecords(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        if(input.containsKey('ApplicationId') && ''+input.get('ApplicationId') != '') {
            delete [SELECT Id FROM Case_Relationship__c WHERE Business_License_Application__c =: ''+input.get('ApplicationId')];
            delete [SELECT Id FROM DocumentChecklistItem WHERE ParentRecordId =: ''+input.get('ApplicationId')];
        }
    }
    
    public static void autoAddRemoveAuthPerson(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> blocks = new Map<String, Object>();
        Boolean addDP = input.get('AddDesignatedPrincipalAsAuthIndividual') == true;
        Boolean existsDP = false;
        Boolean addCL = input.get('AddComplianceLawyerAsAuthIndividual') == true;
        Boolean existsCL = false;
        Boolean changed = false;
        
        List<Map<String,Object>> blockValues = new List<Map<String,Object>>();
        List<Map<String,Object>> newBlockValues = new List<Map<String,Object>>();
        if(String.valueOf(input.get('AuthorizedPersonInformation')) != null && String.valueOf(input.get('AuthorizedPersonInformation')) != '') {
            blocks = (Map<String, Object>) input.get('AuthorizedPersonInformation');
        	if(blocks.containsKey('AuthorizedPersonBlock') && String.valueOf(blocks.get('AuthorizedPersonBlock')) != null && String.valueOf(blocks.get('AuthorizedPersonBlock')) != '') {
                if(blocks.get('AuthorizedPersonBlock') instanceof Map<String, Object>)
                    blockValues.add((Map<String,Object>) blocks.get('AuthorizedPersonBlock'));
                else {
                    List<Object> blockObjs = (List<Object>) blocks.get('AuthorizedPersonBlock');
                    for(Object blockObj : blockObjs) {
                        blockValues.add((Map<String, Object>) blockObj);
                    }
                }
            }
        }
        
        for(Map<String,Object> blockValue : blockValues) {
            changed = true;
            if(''+blockValue.get('AddedFrom') == 'DP' && addDP == false) {}
            else if(''+blockValue.get('AddedFrom') == 'CL' && addCL == false) {}
            else {
                if(''+blockValue.get('AddedFrom') == 'DP') existsDP = true;
                if(''+blockValue.get('AddedFrom') == 'CL') existsCL = true;
            	newBlockValues.add(blockValue);
            }
        }
        
        if(addDP == true && existsDP == false) {
            changed = true;
            existsDP = true;
            Map<String, Object> dpValue = (Map<String, Object>)input.get('DesignatedPrincipalInfo');
            newBlockValues.add(new Map<String, Object> {
            	'AuthorizedPersonTypeFormula' => 'Individual',
                'AuthorizedPersonFirstName' => ''+(dpValue.get('DPFirstName') ?? ''),
                'AuthorizedPersonMiddleName' => ''+(dpValue.get('DPMiddleName') ?? ''),
                'AuthorizedPersonLastName' => ''+(dpValue.get('DPLastName') ?? ''),
                'AuthorizedPersonLegalName' => null,
                'AuthorizedPersonName' => ''+(input.get('DPFullName') ?? ''),
                'AuthorizedPersonType' => 'Individual',
                'AuthorizedPersonTelephone' => ''+(dpValue.get('DPBusinessTelephone') ?? ''),
                'AuthorizedPersonEmail' => ''+(dpValue.get('DPEmail') ?? ''),
                'DoNotCreateUser' => true,
                'AddedFrom' => 'DP'
            });
        }
        
        if(addCL == true && existsCL == false) {
            changed = true;
            existsCL = true;
            Map<String, Object> clValue = (Map<String, Object>)input.get('ComplianceLawyerInfo');
            newBlockValues.add(new Map<String, Object> {
            	'AuthorizedPersonTypeFormula' => 'Individual',
                'AuthorizedPersonFirstName' => ''+(clValue.get('CLFirstName') ?? ''),
                'AuthorizedPersonMiddleName' => ''+(clValue.get('CLMiddleName') ?? ''),
                'AuthorizedPersonLastName' => ''+(clValue.get('CLLastName') ?? ''),
                'AuthorizedPersonLegalName' => null,
                'AuthorizedPersonName' => ''+(input.get('CLFullName') ?? ''),
                'AuthorizedPersonType' => 'Individual',
                'AuthorizedPersonTelephone' => ''+(clValue.get('CLBusinessTelephone') ?? ''),
                'AuthorizedPersonEmail' => ''+(clValue.get('CLEmail') ?? ''),
                'DoNotCreateUser' => true,
                'AddedFrom' => 'CL'
            });
        }
        
        blocks.put('AuthorizedPersonBlock', newBlockValues.isEmpty() ? (changed == false ? null : new List<Object>()) : newBlockValues);
        output.put('AuthorizedPersonInformation', blocks);
    }

    public static void copyPreviousAuthPersons(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        if(input.containsKey('ApplicationId') && ''+input.get('ApplicationId') != '' && input.containsKey('LicenseId') && ''+input.get('LicenseId') != '') {
            List<Case_Relationship__c> addParticipants = new List<Case_Relationship__c>();
            for(Case_Relationship__c participant : [
                SELECT Id,Address__c,Business_License__c,Business_License_Application__c,Business_Name__c,Compliance_Type__c,Date_of_Birth__c,
                Do_not_Send_Sub_Application__c,Email__c,First_Name__c,Has_Economic_Interest__c,Has_Pending_Admission__c,Has_Previously_Submitted__c,
                Has_Right_to_Decision_Making__c,Home_Address__c,Last_Name__c,Middle_Name__c,Ownership__c,Pending_Admission_Date__c,Person_Account__c,
                Phone__c,Previously_Submitted_Date__c,Role__c,Social_Security_Number__c,Status__c
                FROM Case_Relationship__c WHERE Business_License__c =: ''+input.get('LicenseId')
            ]) {
                Case_Relationship__c cloned = participant.clone(false, false, false);
                cloned.Business_License_Application__c = ''+input.get('ApplicationId');
                addParticipants.add(cloned);
            }
            if(!addParticipants.isEmpty())
                insert addParticipants;
        }
    }

    public static void getjBillingPaymentWebPage(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> result = AZSC_LightningController.getjBillingPaymentWebPage(''+input.get('ApplicationId'));
        output.put('PaymentURL', ''+result.get('paymentURL'));
    }

    public static Map<String, Object> doPersonAccountMatch(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        String basequery = 'SELECT Id,PersonContactId FROM Account WHERE RecordType.DeveloperName = \'PersonAccount\' ';
        String nameQuery = '', emailQuery = '', ssnQuery = '', phoneQuery = '', dobQuery = '', lastQuery = 'ORDER BY LastModifiedDate DESC LIMIT 1';
        if((input.containsKey('FirstName') && input.get('FirstName') != null && input.get('FirstName') != '') && (input.containsKey('LastName') && input.get('LastName') != null && input.get('LastName') != '')) 
            nameQuery = 'AND FirstName =: fName AND LastName =: lName ';
        if(input.containsKey('Email') && input.get('Email') != null && input.get('Email') != '') 
            emailQuery = 'AND PersonEmail =: email ';
        if(input.containsKey('SSN') && input.get('SSN') != null && input.get('SSN') != '')
            ssnQuery = 'AND SSN__pc =: ssn ';
        if(input.containsKey('Phone') && input.get('Phone') != null && input.get('Phone') != '')
            phoneQuery = 'AND Phone =: phone ';
        if(input.containsKey('DOB') && input.get('DOB') != null && input.get('DOB') != '')
            dobQuery = 'AND PersonBirthDate =: dob ';
        List<String> queries = new List<String>();
        if(nameQuery != '' && emailQuery != '') //Name and Email
            queries.add(basequery + '' + nameQuery + '' + emailQuery + '' + lastQuery);
        if(nameQuery != '' && ssnQuery != '') //Name and SSN
            queries.add(basequery + '' + nameQuery + '' + ssnQuery + '' + lastQuery);
        if(nameQuery != '' && phoneQuery != '') //Name and Phone
            queries.add(basequery + '' + nameQuery + '' + phoneQuery + '' + lastQuery);
        if(nameQuery != '' && dobQuery != '') //Name and DOB
            queries.add(basequery + '' + nameQuery + '' + dobQuery + '' + lastQuery);
        if(emailQuery != '' && ssnQuery != '') //Email and SSN
            queries.add(basequery + '' + emailQuery + '' + ssnQuery + '' + lastQuery);
        if(emailQuery != '' && phoneQuery != '') //Email and Phone
            queries.add(basequery + '' + emailQuery + '' + phoneQuery + '' + lastQuery);
        if(emailQuery != '' && dobQuery != '') //Email and DOB
            queries.add(basequery + '' + emailQuery + '' + dobQuery + '' + lastQuery);
        if(ssnQuery != '' && phoneQuery != '') //SSN and Phone
            queries.add(basequery + '' + ssnQuery + '' + phoneQuery + '' + lastQuery);
        if(ssnQuery != '' && dobQuery != '') //SSN and DOB
            queries.add(basequery + '' + ssnQuery + '' + dobQuery + '' + lastQuery);
        if(nameQuery != '' && emailQuery != '' && ssnQuery != '' && phoneQuery != '' && dobQuery != '') //ALL
            queries.add(basequery + '' + nameQuery + '' + emailQuery + '' + ssnQuery + '' + phoneQuery + '' + dobQuery + '' + lastQuery);
        Map<String, Object> wrapBinds = new Map<String, Object> {
            'ssn' => input.containsKey('SSN') ? ''+input.get('SSN') : '',
            'email' => input.containsKey('Email') ? ''+input.get('Email') : '',
            'phone' => input.containsKey('Phone') ? ''+input.get('Phone') : '',
            'dob' => input.containsKey('DOB') && input.get('DOB') != null && input.get('DOB') != '' ? Date.valueOf(''+input.get('DOB')) : Null,
            'fname' => input.containsKey('FirstName') ? ''+input.get('FirstName') : '',
            'lname' => input.containsKey('LastName') ? ''+input.get('LastName') : ''
        };
        for(String query : queries) {
            List<Account> matchedAccounts = Database.queryWithBinds(query, wrapBinds, AccessLevel.SYSTEM_MODE);
            if(!matchedAccounts.isEmpty()) {
                output.put('AccountId', matchedAccounts[0].Id);
                output.put('ContactId', matchedAccounts[0].PersonContactId);
                break;
            }
        }
        return output;
    }

    public static Map<String, Object> doBusinessAccountMatch(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        String basequery = 'SELECT Id,AccountId FROM Contact WHERE Account.RecordType.DeveloperName = \'Business_Account\' ';
        String nameQuery = '', emailQuery = '', phoneQuery = '', lastQuery = 'ORDER BY LastModifiedDate DESC LIMIT 1';
        if(input.containsKey('Name') && input.get('Name') != null && input.get('Name') != '')
            nameQuery = 'AND Account.Name =: name ';
        if(input.containsKey('Email') && input.get('Email') != null && input.get('Email') != '') 
            emailQuery = 'AND Email =: email ';
        if(input.containsKey('Phone') && input.get('Phone') != null && input.get('Phone') != '')
            phoneQuery = 'AND Phone =: phone ';
        List<String> queries = new List<String>();
        if(nameQuery != '' && emailQuery != '') //Name and Email
            queries.add(basequery + '' + nameQuery + '' + emailQuery + '' + lastQuery);
        if(nameQuery != '' && phoneQuery != '') //Name and Phone
            queries.add(basequery + '' + nameQuery + '' + phoneQuery + '' + lastQuery);
        if(emailQuery != '' && phoneQuery != '') //Email and Phone
            queries.add(basequery + '' + emailQuery + '' + phoneQuery + '' + lastQuery);
        if(nameQuery != '' && emailQuery != '' && phoneQuery != '') //ALL
            queries.add(basequery + '' + nameQuery + '' + emailQuery + '' + phoneQuery + '' + lastQuery);
        Map<String, Object> wrapBinds = new Map<String, Object> {
            'email' => input.containsKey('Email') ? ''+input.get('Email') : '',
            'phone' => input.containsKey('Phone') ? ''+input.get('Phone') : '',
            'name' => input.containsKey('Name') ? ''+input.get('Name') : ''
        };
        for(String query : queries) {
            List<Contact> matchedContacts = Database.queryWithBinds(query, wrapBinds, AccessLevel.SYSTEM_MODE);
            if(!matchedContacts.isEmpty()) {
                output.put('AccountId', matchedContacts[0].AccountId);
                output.put('ContactId', matchedContacts[0].Id);
                break;
            }
        }
        return output;
    }

    public static void fetchApplications(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        if(input.containsKey('UserId') && input.get('UserId') <> Null) {
            List<Map<String, Object>> applications = AZSC_LightningController.fetchApplications(''+input.get('UserId'));
            output.put('result', applications);
        }
    }

    public static void fetchLicenses(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        if(input.containsKey('UserId') && input.get('UserId') <> Null) {
            List<User> users = [SELECT Id,AccountId,Account.Type,ContactId FROM User WHERE Id =: ''+input.get('UserId') LIMIT 1];
            if(users[0].ContactId == null)
                return;
            List<Map<String, Object>> unifiedList = new List<Map<String, Object>>();
            Map<String,BusinessLicense> licenses = new Map<String,BusinessLicense>();
            
            //Business Primary Point of Contact
            for(BusinessLicense license : [
                SELECT Id, Name, AccountId, Account.Name, PeriodStart, PeriodEnd, Status, RegulatoryAuthorizationType.RegulatoryAuthCode,
                RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.Renewal_Open_Duration__c, Business_Type__c, 
                Good_Cause_Exception__c, VerificationStatus FROM BusinessLicense WHERE ContactId =: users[0].ContactId
            ]) {
                licenses.put(license.Id, license);
                String actionName = '';
                Integer currYear = license.PeriodEnd.addYears(-1).Year();
                Date janDate = Date.newInstance(currYear, 1, 01);
                Date febDate = Date.newInstance(currYear, 2, 28);
                Date currDate = System.today();
                Boolean openForRenewal = false;
                if(license.Status == AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c || 
                   license.Status == AZSC_Constant__mdt.getInstance('LicenseStateGoodCauseExempt').Value__c) 
                {
                    openForRenewal = true;
                    actionName = 'Renew';
                }
                else if(license.Status == AZSC_Constant__mdt.getInstance('LicenseStatusInActive').Value__c) {
                    actionName = 'Reinstate';
                }
                if(license.VerificationStatus == 'Partial Payment Pending' && (currDate >= janDate && currDate <= febDate)) {
                    actionName = 'Pay Now';
                }
                unifiedList.add(new Map<String, Object>{
                    'LicenseId' => license.Id,
                    'LicenseNum' => license.Name,
                    'LicenseName' => license.RegulatoryAuthorizationType.Name,
                    'PeriodStart' => license.PeriodStart,
                    'PeriodEnd' => license.PeriodEnd,
                    'Status' => license.Status,
                    'BusinessId' => license.AccountId,
                    'Business' => license.Account.Name,
                    'BusinessType' => license.Business_Type__c,
                    'Role' => 'Applicant',
                    'PayStatus' => license.VerificationStatus,
                    'OpenRenewal' => license.RegulatoryAuthorizationType.RegulatoryAuthCode == 'ABSLicense' ? false : openForRenewal,
                    'OpenReinstate' => license.Status == AZSC_Constant__mdt.getInstance('LicenseStatusInActive').Value__c ? true : false,
                    'Action' => license.RegulatoryAuthorizationType.RegulatoryAuthCode == 'ABSLicense' ? '' : actionName
                });
            }

            //Business Contact from Participants
            for(Case_Relationship__c participant : [
                SELECT Role__c,Business_License__c,Business_License__r.Name,Business_License__r.AccountId,Business_License__r.Account.Name,
                Business_License__r.PeriodStart,Business_License__r.PeriodEnd,Business_License__r.Status,Business_License__r.RegulatoryAuthorizationType.Name,
                Business_License__r.RegulatoryAuthorizationType.Renewal_Open_Duration__c,Business_License__r.Business_Type__c
                FROM Case_Relationship__c WHERE Person_Account__c =: users[0].AccountId AND Business_License__c != NULL
            ]) {
                if(!licenses.containsKey(participant.Business_License__c)) {
                    licenses.put(participant.Business_License__c, new BusinessLicense(Id = participant.Business_License__c));
                    unifiedList.add(new Map<String, Object>{
                        'LicenseId' => participant.Business_License__r.Id,
                        'LicenseNum' => participant.Business_License__r.Name,
                        'LicenseName' => participant.Business_License__r.RegulatoryAuthorizationType.Name,
                        'PeriodStart' => participant.Business_License__r.PeriodStart,
                        'PeriodEnd' => participant.Business_License__r.PeriodEnd,
                        'Status' => participant.Business_License__r.Status,
                        'BusinessId' => participant.Business_License__r.AccountId,
                        'Business' => participant.Business_License__r.Account.Name,
                        'BusinessType' => participant.Business_License__r.Business_Type__c,
                        'Role' => participant.Role__c,
                        'OpenRenewal' => (participant.Role__c == 'Compliance Lawyer' || participant.Role__c == 'Designated Principal') && participant.Business_License__r.Status == AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c,
                        'Action' => ((participant.Role__c == 'Compliance Lawyer' || participant.Role__c == 'Designated Principal') && participant.Business_License__r.Status == AZSC_Constant__mdt.getInstance('LicenseStatusRenewalPending').Value__c) == true ? 'Renew' : ''
                    });
                }
            }
            
            Map<Id,List<IndividualApplication>> existingIndApplns = new Map<Id,List<IndividualApplication>>();
            for(IndividualApplication existingIndAppln : [SELECT Id,ApplicationType,LicensePermitNameId,CreatedDate,LicensePermitName.PeriodStart,LicensePermitName.PeriodEnd FROM IndividualApplication WHERE LicensePermitNameId IN: licenses.keySet()]) {
                if(existingIndAppln.ApplicationType != Null && existingIndAppln.ApplicationType.contains('Renewal') && existingIndAppln.CreatedDate >= existingIndAppln.LicensePermitName.PeriodStart && existingIndAppln.CreatedDate <= existingIndAppln.LicensePermitName.PeriodEnd) {
                    if(!existingIndApplns.containsKey(existingIndAppln.LicensePermitNameId))
                        existingIndApplns.put(existingIndAppln.LicensePermitNameId, new List<IndividualApplication>());
                    existingIndApplns.get(existingIndAppln.LicensePermitNameId).add(existingIndAppln);
                }
            }

            Map<Id,List<BusinessLicenseApplication>> existingApplns = new Map<Id,List<BusinessLicenseApplication>>();
            for(BusinessLicenseApplication existingAppln : [SELECT Id,ApplicationType,LicensePermitNameId,CreatedDate,LicensePermitName.PeriodStart,LicensePermitName.PeriodEnd FROM BusinessLicenseApplication WHERE LicensePermitNameId IN: licenses.keySet()]) {
                if(existingAppln.ApplicationType != Null && existingAppln.ApplicationType.contains('Renewal') && existingAppln.CreatedDate >= existingAppln.LicensePermitName.PeriodStart && existingAppln.CreatedDate <= existingAppln.LicensePermitName.PeriodEnd) {
                    if(!existingApplns.containsKey(existingAppln.LicensePermitNameId))
                        existingApplns.put(existingAppln.LicensePermitNameId, new List<BusinessLicenseApplication>());
                    existingApplns.get(existingAppln.LicensePermitNameId).add(existingAppln);
                }
            }

            for(Map<String, Object> wrapper : unifiedList) {
                if(existingIndApplns.containsKey(''+wrapper.get('LicenseId')) || existingApplns.containsKey(''+wrapper.get('LicenseId'))) {
                    wrapper.put('OpenRenewal', false);
                    if(wrapper.get('Action') == 'Renew') {
                        wrapper.put('Action', '');
                    }
                }
            }
            output.put('result', unifiedList);
        }
    }

    public static void checkSubApplicationDue(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        output.put('HasDue', true);
        if(input.containsKey('ABSApplicationId') && input.containsKey('AppType')) {
            String role = ''+input.get('AppType') == 'ABSAuthEntitySub' ? 'Authorized Person (Entity)' : (
                ''+input.get('AppType') == 'ABSAuthIndividualSub' ? 'Authorized Person (Individual)' : (
                    ''+input.get('AppType') == 'ABSComplianceSub' ? 'Compliance Lawyer' : (
                        ''+input.get('AppType') == 'ABSDesignatedSub' ? 'Designated Principal' : ''
                    )
                )
            );
            String applnId = ''+input.get('ABSApplicationId');
            List<Map<String, Object>> applications = AZSC_LightningController.fetchApplications(UserInfo.getUserId());
            for(Map<String, Object> application : applications) {
                if(''+application.get('Role') == role && application.get('HasSubApplnDue') == false)
                    output.put('HasDue', false);
            }
        }
    }

	public static void createUser(Map<String,Object> args) {
        Map<String, Object> params = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        String email = ''+params.get('Email');
		List<User> users = [SELECT Id FROM User WHERE IsPortalEnabled = true AND Email =: email];
        if(!users.isEmpty())
            output.put('Duplicate', true);
        else {
            Id contactId, accountId;
            User adminUsr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRole.Name = 'System Admin' AND IsActive = TRUE LIMIT 1][0];
            Account accRec = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get((String)params.get('CustomerType')).getRecordTypeId(),
                OwnerId = adminUsr.Id
            );
            if((String)params.get('CustomerType') == 'Business_Account') {
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
            if((String)params.get('CustomerType') == 'Business_Account') {
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
            output.put('Duplicate', false);
            output.put('UserId', usrRec.Id);
        }
	}
}