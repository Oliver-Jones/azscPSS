/**
* @File Name : AZSC_JBillingPayload.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 14, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 14, 2025 |   | Initial Version
**/

public class AZSC_JBillingPaymentService {
	public class JBillingPayload {
		@AuraEnabled
		public String endPointURL;
		@AuraEnabled
		public String gAOTransactionType;
		@AuraEnabled
		public String gAOTransactionInstance;
		@AuraEnabled
		public String merchantName;
		@AuraEnabled
		public String merchantNumber;
		@AuraEnabled
		public String service;
		@AuraEnabled
		public String orderNumber;
		@AuraEnabled
		public String gAOAgency;
		@AuraEnabled
		public String dOCAgency;
		@AuraEnabled
		public String amount;
		@AuraEnabled
		public String paymentMethod;
		@AuraEnabled
		public String returnURL;
		@AuraEnabled
		public String summaryDescription;
		@AuraEnabled
		public List<LineItem> lineItems;
	}

	public class LineItem {
		@AuraEnabled
		public String gAOProductCode;
		@AuraEnabled
		public String gAOAgency;
		@AuraEnabled
		public String function;
		@AuraEnabled
		public String revenueSource;
		@AuraEnabled
		public String departmentRevenueSource;
		@AuraEnabled
		public String accountingTemplate;
		@AuraEnabled
		public String gAODescription;
		@AuraEnabled
		public String amount;
		@AuraEnabled
		public String quantity;
	}

	public static Map<String, Object> getOrderURL(JBillingPayload payload) {
		Map<String, Object> output = new Map<String, Object>();
		DOM.Document doc = new DOM.Document();        
        dom.XmlNode envelope = doc.createRootElement('gaoTransactionType', payload.gAOTransactionType, payload.gAOTransactionInstance); //http://payment.az.gov, ns2
        dom.XmlNode body1 = envelope.addChildElement('merchantName', null, null).addTextNode(payload.merchantName);//SPA_TEST
        dom.XmlNode body2 = envelope.addChildElement('merchantNumber', null, null).addTextNode(payload.merchantNumber);//SPA_TEST
        dom.XmlNode body3 = envelope.addChildElement('service', null, null).addTextNode(payload.service);//SPA_TEST_PAYMENT
        dom.XmlNode body4 = envelope.addChildElement('orderNumber', null, null).addTextNode(payload.orderNumber);//0000000000'0000000264'
        dom.XmlNode body5 = envelope.addChildElement('gaoBatchAgency', null, null).addTextNode(payload.gAOAgency);//SPA
        dom.XmlNode body6 = envelope.addChildElement('gaoDocNoAgency', null, null).addTextNode(payload.dOCAgency);//SPA
        dom.XmlNode body7 = envelope.addChildElement('totalAmount', null, null).addTextNode(payload.amount);
        dom.XmlNode body11 = envelope.addChildElement('paymentType', null, null).addTextNode(payload.paymentMethod);
        dom.XmlNode body8 = envelope.addChildElement('returnURL', null, null).addTextNode(payload.returnURL);
        dom.XmlNode body9 = envelope.addChildElement('summaryDescription', null, null).addTextNode(payload.summaryDescription);
        dom.XmlNode body12 = envelope.addChildElement('lineItemList', null, null);
        for(LineItem item : payload.lineItems) {
            dom.XmlNode body13 = body12.addChildElement('lineItem', null, null);
			dom.XmlNode body14 = body13.addChildElement('gaoProductCode', null, null).addTextNode(item.gAOProductCode);//Primary_GL_Account__c
            dom.XmlNode body15 = body13.addChildElement('gaoAgency', null, null).addTextNode(item.gAOAgency);
			dom.XmlNode body16 = body13.addChildElement('function', null, null).addTextNode(item.function);//Function__c
			dom.XmlNode body17 = body13.addChildElement('revenueSource', null, null).addTextNode(item.revenueSource);//Product_Revenue_Source__c
			dom.XmlNode body18 = body13.addChildElement('departmentRevenueSource', null, null).addTextNode(item.departmentRevenueSource);//Product_Revenue_Source__c                
            dom.XmlNode body19 = body13.addChildElement('accountingTemplate', null, null).addTextNode(item.accountingTemplate);
			dom.XmlNode body20 = body13.addChildElement('gaoDescription', null, null).addTextNode(item.gAODescription);//Product_Description__c
			dom.XmlNode body22 = body13.addChildElement('amount', null, null).addTextNode(item.amount);
            dom.XmlNode body23 = body13.addChildElement('quantity', null, null).addTextNode(item.quantity);
        }
        System.debug('CREATED XML'+ doc.toXmlString());
        // Send the request
        HttpRequest jBillingRequest = new HttpRequest();
        Http jBillingHTTP = new Http();
        jBillingRequest.setMethod('POST');      
        jBillingRequest.setEndpoint(payload.endPointURL);
        jBillingRequest.setHeader('Content-Type', 'text/xml');
        jBillingRequest.setBodyDocument(doc);       
        HttpResponse jBillingResponse = jBillingHTTP.send(jBillingRequest);
		output.put('paymentURL', jBillingResponse.getBody());
		output.put('success', true);
        return output;
    }
}