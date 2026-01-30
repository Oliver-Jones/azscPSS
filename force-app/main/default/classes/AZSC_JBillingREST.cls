/**
* @File Name : AZSC_JBillingREST.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 16, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 16, 2025 |   | Initial Version
**/
@RestResource(urlMapping='/v1/jbillsgate')
global class AZSC_JBillingREST {
    //post method that process third party request
    @HttpPost 
    global static void acceptRequest() {
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        resp.addHeader('Cache-Control','max-age=0');
        resp.addHeader('content-type', 'text/plain; charset=UTF-8');
        if(req.params.containsKey(AZSC_Constant__mdt.getInstance('jBillPaymentStatus').Value__c) && req.params.containsKey(AZSC_Constant__mdt.getInstance('jBillOrderNumber').Value__c)) {
            String feeNum = ('Fee-'+req.params.get(AZSC_Constant__mdt.getInstance('jBillOrderNumber').Value__c)).trim();
            List<RegulatoryTrxnFee> fees = [SELECT Id,ParentRecordId,From_Portal__c FROM RegulatoryTrxnFee WHERE Name =: feeNum LIMIT 1];
            if(!fees.isEmpty()) {
                fees[0].Response_JSON__c = ''+req;
                if(req.params.get(AZSC_Constant__mdt.getInstance('jBillPaymentStatus').Value__c) == '1') {
                    insert new Payment__c(
                        Regulatory_Transaction_Fee__c = fees[0].Id,
                        Business_License_Application__c = fees[0].ParentRecordId,
                        Authorization_Code__c = req.params.get(AZSC_Constant__mdt.getInstance('jBillAuthCode').Value__c),
                        PayStatus__c = req.params.get(AZSC_Constant__mdt.getInstance('jBillPaymentStatus').Value__c),
                        Order_Number__c = req.params.get(AZSC_Constant__mdt.getInstance('jBillOrderNumber').Value__c)
                    );
                    fees[0].Status = AZSC_Constant__mdt.getInstance('FeeStatusPaid').Value__c;
                    update fees[0];
                    String redirectUrl = generateCommunityURL()+'/complete?appType=InitialLicenseAppln&ApplicationId='+fees[0].ParentRecordId;
                    //String html = '<html><head><script>window.location.href="' + redirectUrl + '";</script></head><body>If you are not redirected, <a href="' + redirectUrl + '">click here</a>.</body></html>';
                    //resp.addHeader('Content-Type', 'text/html');
                    //resp.responseBody = Blob.valueOf(html);
                    resp.statusCode = 200;
                    if(fees[0].From_Portal__c != true) {
                        update new BusinessLicenseApplication(Id = fees[0].ParentRecordId, Status = 'Waiting for Sub Applications');
                        redirectURL = URL.getOrgDomainURL().toExternalForm() + '/' + fees[0].ParentRecordId;
                    }
                    resp.addHeader('Location', redirectUrl);
                    
                }
                else {
                    fees[0].Status = AZSC_Constant__mdt.getInstance('FeeStatusCanceled').Value__c;
                    update fees[0];
                    String redirectUrl = generateCommunityURL()+'/applications';
                    //String html = '<html><head><script>window.location.href="' + redirectUrl + '";</script></head><body>If you are not redirected, <a href="' + redirectUrl + '">click here</a>.</body></html>';
                    //resp.addHeader('Content-Type', 'text/html');
                    //resp.responseBody = Blob.valueOf(html);
                    resp.statusCode = 200;
                    resp.addHeader('Location', redirectUrl);
                }
            }
            else {
                handleError(resp, 'no_fee');
            }
        }
        else {
            handleError(resp, 'fatal');
        }
    }

    public static void handleError(RestResponse resp, String text) {
        String redirectUrl = generateCommunityURL()+'/error';
        String html = '<html><head><script>window.location.href="' + redirectUrl + '";</script></head><body>If you are not redirected, <a href="' + redirectUrl + '">click here</a>.</body></html>';
        resp.statusCode = 200;
        resp.addHeader('Content-Type', 'text/html');
        resp.responseBody = Blob.valueOf(html);
    }
    
    public static String generateCommunityURL() {
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        return AZSC_Constant__mdt.getInstance(org.IsSandbox ? 'CommunityURL' : 'CommunityLiveURL').Value__c;
    }
}