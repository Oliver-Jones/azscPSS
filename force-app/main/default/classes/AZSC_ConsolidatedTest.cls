@isTest
public class AZSC_ConsolidatedTest {
    @testsetup
    private static void loadData() {
        Reference_Application__c ref = new Reference_Application__c();
        insert ref;
        insert new Application__c(Reference_Application__c = ref.Id);
        Account acc = new Account(Name = 'Test', Phone = '1234567890');
        insert acc;
        Case caseRec = new Case(AccountId = acc.Id);
        insert caseRec;
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'ABS Application');
        insert licenseType;
        insert new BusinessLicenseApplication(ApplicationCaseId = caseRec.Id, AccountId = acc.Id, AppliedDate = System.now(), LicenseTypeId = licenseType.Id, Category = 'License');
    }
    
	@isTest
    private static void omniScriptUtilitiesCheck() {
        BusinessLicenseApplication appln = [SELECT Id,AccountId FROM BusinessLicenseApplication LIMIT 1][0];
        AZSC_OmniScriptUtilities ctrl = new AZSC_OmniScriptUtilities();
        ctrl.call('submitDocumentChecklistItems', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ParentRecordId' => appln.Id,
                'DocumentUploads' => new Map<String, Object>{
                    'Block9' => new Map<String, Object>{'documentName9' => 'Test', 'File9' => new List<Map<String, Object>>{new Map<String, Object>{'key' => 'value'}}}
                 }
            },
            'output' => new Map<String,Object>()
        });
        ctrl.call('insertRegTrxnFeeItems', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ApplicationId' => appln.Id,
                'AccountId' => appln.AccountId,
                'FeeType' => 'ABS Initial Licensure',
                'Fee' => '6000',
                'Function' => '123',
                'ProductCode' => '123',
                'RevenueSource' => '123'
            },
            'output' => new Map<String,Object>()
        });
        RegulatoryTrxnFee fee = [SELECT Id FROM RegulatoryTrxnFee WHERE ParentRecordId =: appln.Id LIMIT 1][0];
        ctrl.call('getRegTrxnFeeItems', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'regTrxnFeeId' => fee.Id
             },
             'output' => new Map<String,Object>()
      	});
        ctrl.call('UpdateApplnStatusToPaymentPending', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'applnId' => appln.Id
             },
             'output' => new Map<String,Object>()
        });
        Case csRec = [SELECT Id FROM Case LIMIT 1][0];
        ctrl.call('insertAuthorizedPersons', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ApplicationId' => appln.Id,
                'CaseId' => csRec.Id,
                'AuthorizedPersonInformation' => new Map<String,List<Object>>{
                    'AuthorizedPersonBlock' => new List<Map<String,Object>>{
                        new Map<String,Object>{
                            'AuthorizedPersonFirstName' => 'Drake',
                            'AuthorizedPersonLastName' => 'Jim',
                            'AuthorizedPersonEmail' => 'jimdrake1224@yopmail.com',
                            'AuthorizedPersonTelephone' => '1231411412',
                            'AuthorizedPersonType' => 'Individual'
                        },
                        new Map<String,Object>{
                            'AuthorizedPersonLegalName' => 'ABC Corp',
                            'AuthorizedPersonEmail' => 'abccorp1224@yopmail.com',
                            'AuthorizedPersonTelephone' => '1231411412',
                            'AuthorizedPersonType' => 'Entity',
                            'AuthorizedPersonPOCLastName' => 'Demogorgan'
                        }
                    }
                }
            },
            'output' => new Map<String,Object>()
        });
        ctrl.call('upsertParticipant', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ParticipantType' => 'Individual',
                'ApplicationId' => appln.Id,
                'CaseId' => csRec.Id,
            	'FirstName' => 'John',
                'LastName' => 'Doe',
                'SSN' => '123456789',
                'Email' => 'a@a.a',
                'Phone' => '1234567890',
                'DOB' => System.today()
            },
            'output' => new Map<String,Object>()
        });
        ctrl.call('upsertParticipant', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ParticipantType' => 'Entity',
                'ApplicationId' => appln.Id,
                'CaseId' => csRec.Id,
                'Name' => 'John Hughes',
            	'FirstName' => 'John',
                'LastName' => 'Doe',
                'SSN' => '123456789',
                'Email' => 'a@a.a',
                'Phone' => '1234567890',
                'DOB' => System.today(),
                'POCLastName' => 'Demogorgan'
            },
            'output' => new Map<String,Object>()
        });
        Account b2bAcc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ABS_Entity').getRecordTypeId(), Name = 'Demo', Phone = '0987654321');
        insert b2bAcc;
        insert new Contact(AccountId = b2bAcc.Id, LastName = 'Someone', Phone = '0987654321');
        insert new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(), FirstName = 'John', LastName = 'Doe', Phone = '1234567890');
        ctrl.call('findMatchedPersonAccount', new Map<String,Object>{
            'input' => new Map<String,Object>{
            	'FirstName' => 'John',
                'LastName' => 'Doe',
                'SSN' => '1234567890',
                'Email' => 'a@a.a',
                'Phone' => '1234567890',
                'DOB' => System.today()
            },
            'output' => new Map<String,Object>()
        });
        ctrl.call('findMatchedBusinessAccount', new Map<String,Object>{
            'input' => new Map<String,Object>{
            	'Name' => 'Demo',
                'SSN' => '1234567890',
                'Email' => 'a@a.a',
                'Phone' => '0987654321'
            },
            'output' => new Map<String,Object>()
        });
    }
    
    @isTest
    private static void lightningControllerCheck() {
        AZSC_LightningController.fetchApplications();
        User usr = [SELECT Id,ContactId FROM User WHERE isPortalEnabled = true AND isActive = true LIMIT 1][0];
        insert new OmniScriptSavedSession(Name = 'Omni Test', StatusCategory = 'In Progress', RelatedRecordIdentifier = usr.Id);
        BusinessLicenseApplication appln = [SELECT Id,AccountId FROM BusinessLicenseApplication LIMIT 1][0];
        appln.ApplicantId = usr.ContactId;
        update appln;
        System.runAs(usr) {
            AZSC_LightningController.fetchApplications();
        }
        AZSC_LightningController.createUser(new Map<String,Object>{
            'accessType' => 'Business_Account',
            'CompanyName' => 'Iam',
            'FirstName' => 'So',
            'LastName' => 'Hungry',
            'Email' => 'americastuck@thehandsoftrump.com'
        });
        AZSC_LightningController.createUser(new Map<String,Object>{
            'accessType' => 'PersonAccount',
            'CompanyName' => 'Demo',
            'FirstName' => 'Pro',
            'LastName' => 'Coder',
            'Email' => 'thiswillpass@thistest.com'
        });
        AZSC_LightningController.checkDupicateUser('americastuck@thehandsoftrump.com');
    }
    
    @isTest
    private static void jBillingPaymentServiceCheck() {
        BusinessLicenseApplication appln = [SELECT Id,AccountId FROM BusinessLicenseApplication LIMIT 1][0];
        AZSC_OmniScriptUtilities ctrl = new AZSC_OmniScriptUtilities();
        ctrl.call('insertRegTrxnFeeItems', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ApplicationId' => appln.Id,
                'AccountId' => appln.AccountId,
                'FeeType' => 'ABS Initial Licensure',
                'Fee' => '6000',
                'Function' => '123',
                'ProductCode' => '123',
                'RevenueSource' => '123'
            },
            'output' => new Map<String,Object>()
        });
        Test.setMock(HttpCalloutMock.class, new AZSC_ConsolidatedTest.MockGenerator());
        Test.startTest();
        AZSC_LightningController.getjBillingPaymentWebPage(appln.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void jBillingRESTCheck() {
        BusinessLicenseApplication appln = [SELECT Id,AccountId FROM BusinessLicenseApplication LIMIT 1][0];
        AZSC_OmniScriptUtilities ctrl = new AZSC_OmniScriptUtilities();
        ctrl.call('insertRegTrxnFeeItems', new Map<String,Object>{
            'input' => new Map<String,Object>{
                'ApplicationId' => appln.Id,
                'AccountId' => appln.AccountId,
                'FeeType' => 'ABS Initial Licensure',
                'Fee' => '6000',
                'Function' => '123',
                'ProductCode' => '123',
                'RevenueSource' => '123'
            },
            'output' => new Map<String,Object>()
        });
        RegulatoryTrxnFee fee = [SELECT Id,Name FROM RegulatoryTrxnFee WHERE ParentRecordId =: appln.Id LIMIT 1][0];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/v1/billsgate';
        req.httpMethod = 'POST';
        req.addParameter('partialACH', '123456');
        req.addParameter('ACHType', 'Checking');
        req.addParameter('paymentStatus', '0');
        req.addParameter('authorizationCode', 'AUTH123');
        req.addParameter('CCN', '4111111111111111');
        req.addParameter('creditCardType', 'Visa');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        AZSC_JBillingREST.acceptRequest();
        
        req.addParameter('orderNumber', fee.Name.remove('FEE-'));
        AZSC_JBillingREST.acceptRequest();
        
        req.addParameter('paymentStatus', '1');
        RestContext.request = req;
        AZSC_JBillingREST.acceptRequest();
        Test.stopTest();     
    }
    
    public class MockGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setBody('{"example":"test"}');
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            if(request.getEndpoint().containsIgnoreCase(org.IsSandbox ? Jbilling_Merchant_Info__mdt.getInstance('Arizona_Supreme_Court').ADO_Test_Endpoint_URL__c : Jbilling_Merchant_Info__mdt.getInstance('Arizona_Supreme_Court').ADO_END_Point__c))
                response.setBody('url=https://az.stagingaz.gov/scs/#/paymentInformation?purchaseId=145896&error=0&lang=en');
            response.setStatusCode(200);
            return response; 
        }
    }
}