/**
* @File Name : MastekOmnistudioController.cls
* @Description :
* @Author : Oliver
* @Last Modified By : Oliver
* @Last Modified On : August 6, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 6, 2025 | Oliver  | Initial Version
**/

public without sharing class MastekOmnistudioController implements Callable {
	public Object call(String action, Map<String, Object> args) {
        if(action == 'GetPaymentURL') {
            fetchPaymentURL(args);
        }
        else if(action == 'SubmitDocumentUploads') {
            submitDocumentChecklistItems(args);
        }
        else if(action == 'GenerateApplicationPDF') {
            generateServerSidePDF(args);
        }
        return null;
    }

	public static void fetchPaymentURL(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object> ) args.get('input');
        Map<String, Object> options = (Map<String, Object> ) args.get('options');
        Map<String, Object> output = (Map<String, Object> ) args.get('output');
		//Add Payment HTTP Callout Logic here
		output.put('PaymentURL', String.format('https://paymentform.test.webfeepay.com/?clientId={0}&orderId={1}', new List<Object> {'12345', '12345'}));
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

    public static void generateServerSidePDF(Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        String recordId = (String) input.get('ParentRecordId');
        String templateAPI = (String) input.get('TemplateUniqueName');
        String docTitle = (String) input.get('DocumentTitle');
        List<DocumentTemplate> templates = [SELECT Id FROM DocumentTemplate WHERE UniqueName =: templateAPI AND IsActive = true];
        input.put('objectId', recordId);
        input.put('templateId', !templates.isEmpty() ? templates[0].Id : Null);
        input.put('title', docTitle);
        input.put('outputFileFormat', 'pdf');
        input.put('contextId', recordId);
        input.put('keepIntermediate', true);
        input.put('returnAsPdf', true);
        Omnistudio.DocumentServiceGateway ctrl = new Omnistudio.DocumentServiceGateway();
        ctrl.invokeMethod('generateDocument', input, output, options);
    }

    @AuraEnabled(cacheable=false)
    public static void generateApplicationPDF(String recordId, String templateAPI, String docTitle) {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<DocumentTemplate> templates = [SELECT Id FROM DocumentTemplate WHERE UniqueName =: templateAPI AND IsActive = true];
        input.put('objectId', recordId);
        input.put('templateId', !templates.isEmpty() ? templates[0].Id : Null);
        input.put('title', docTitle);
        input.put('outputFileFormat', 'pdf');
        input.put('contextId', recordId);
        input.put('keepIntermediate', true);
        input.put('returnAsPdf', true);
        Omnistudio.DocumentServiceGateway ctrl = new Omnistudio.DocumentServiceGateway();
        ctrl.invokeMethod('generateDocument', input, output, options);
    }
}