import { LightningElement, api, track, wire } from 'lwc'
import fetchApplications from '@salesforce/apex/AZSC_LightningController.fetchApplications'
import paymentModal from 'c/aZSC_PaymentNoteModal'
import newApplnModal from 'c/aZSC_ApplnLaunchModal'
import getjBillingPaymentWebPage from '@salesforce/apex/AZSC_LightningController.getjBillingPaymentWebPage'
import { CurrentPageReference } from "lightning/navigation"
import { NavigationMixin } from "lightning/navigation"
import userId from '@salesforce/user/Id'
export default class AZSC_MyApplications extends NavigationMixin(LightningElement) {
    userId = userId
    showPaymentRedirect = false
    @api type
    @track allApplnData = []
    applnData
    /*applnColumns = []
    defaultSortDirection = "asc"
    sortDirection = "asc"
    sortedBy
    applnType = 'All'*/
    recordSize = 10

    @wire(CurrentPageReference)
    currentPageRef

    get showNewAppln() {
        return this.type == 'Main' && this.allApplnData.length === 0 ? true : false
    }

    get showNoDataMessage() {
        return this.allApplnData.length === 0
    }

    get isMain() {
        return this.type == 'Main' ? true : false
    }

    get isSub() {
        return this.type == 'Sub' ? true : false
    }

    /*
    get filteredData() {
        if(this.applnType == 'All')
            return this.allApplnData
        else
            return this.allApplnData.map(val => val.ApplnType == this.applnType)
    }

    get options() {
        return [
            { label: 'All', value: 'All' },
            { label: 'ABS Applications', value: 'ABS Application' }
        ]
    }*/

    connectedCallback() {
        /*if(this.type == 'Sub') {
            this.applnColumns = [
                { label: 'Application Type', fieldName: 'ApplnType', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Organization Name', fieldName: 'Business', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Number', type: 'url', fieldName: 'ApplnURL', hideDefaultActions: true, sortable: true, wrapText: true, typeAttributes: { label: { fieldName: 'ApplnName' } } },
                { label: 'Role', fieldName: 'Role', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Status', fieldName: 'ApplnStatus', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Received Date', fieldName: 'AppliedDate', hideDefaultActions: true, sortable: true, wrapText: true },
                { type: 'action', label: 'Action', hideDefaultActions: true, wrapText: true, fixedWidth: 100, typeAttributes: { rowActions: this.getRowActions } },
            ]
        }
        else {
            this.applnColumns = [
                { label: 'Application Type', fieldName: 'ApplnType', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Organization Name', fieldName: 'Business', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Number', type: 'url', fieldName: 'ApplnURL', hideDefaultActions: true, sortable: true, wrapText: true, typeAttributes: { label: { fieldName: 'ApplnName' } } },
                //{ label: 'Certification Number', fieldName: 'CertName', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Status', fieldName: 'ApplnStatus', hideDefaultActions: true, sortable: true, wrapText: true },
                { label: 'Application Received Date', fieldName: 'AppliedDate', hideDefaultActions: true, sortable: true, wrapText: true },
                { type: 'action', label: 'Action', hideDefaultActions: true, wrapText: true, fixedWidth: 100, typeAttributes: { rowActions: this.getRowActions } },
            ]
        }
        fetchApplications({
            userId : userId
        })
        .then(result => {
            let temp = [];
            result.forEach(element => {
                temp.push({
                    "Identifier" : element.Identifier,
                    "ApplnURL" : element.ApplnId ? '/detail/'+element.ApplnId : "",
                    "ApplnId" : element.ApplnId,
                    "ApplnType" : element.ApplnType,
                    "Business" : element.Business,
                    "ApplnName" : element.ApplnName,
                    "CertName" : element.CertName,
                    "ApplnStatus" : element.ApplnStatus,
                    "AppliedDate" : String(new Date(element.AppliedDate).getMonth() + 1).padStart(2, '0')+'-'+String(new Date(element.AppliedDate).getDate()).padStart(2, '0')+'-'+new Date(element.AppliedDate).getFullYear(),
                    "IsResume" : element.IsResume,
                    "ResumeURL" : element.ResumeURL,
                    "IsPayDue" : element.IsPayLater,
                    "Role" : element.Role,
                    "HasSubApplnDue" : element.HasSubApplnDue == true ? true : false
                    //"IsInspectionRequest" : (element.Status=='Approved'? true : false),
                    //"InspectionRequestURL" : '/nevada/s/inspectionrequest?recordId='+element.Id
                })
            })
            this.allApplnData = [...this.allApplnData, ...temp]
        })
        .catch(error => {
            
        })*/
    }

    renderedCallback() {
        /*let style = document.createElement('style')
        style.innerText = '.slds-th__action{background: rgb(0, 36, 88) !important; color:white;} .slds-table_header-fixed_container{overflow-x: hidden !important;}'
        this.template.querySelector('lightning-datatable').appendChild(style)*/
        if(this.currentPageRef.state.c__applnId && sessionStorage.getItem('redirected')) {
            this.showPaymentRedirect = true
            sessionStorage.removeItem('redirected');
            getjBillingPaymentWebPage({
                applnId : this.currentPageRef.state.c__applnId
            }).then(result => {
                console.log('jBilling Order URL '+JSON.stringify(result))
                if(result.success == true) {
                    window.location.href = result.paymentURL
                }
            })
        }
    }
    
    async newAppln() {
        const result = await newApplnModal.open({
            size: 'small',
            description: ''
        })
        /*this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "ABS_Application__c"
            },
            state: {
                //c__applnId : row['ApplnId']
            }
        })*/
    }

    handleChange(event) {
        this.applnType = event.target.value
    }

    /*getRowActions(row, doneCallback) {
        const actions = [];
        if (row['IsResume']) {
            actions.push({
                'label': 'Resume Application',
                'iconName': 'utility:edit',
                'name': 'resume'
            });
        }
        else if(row['IsPayDue']) {
            actions.push({
                'label': 'Pay Now',
                'iconName': 'utility:checkout',
                'name': 'paynow'
            });
        }
        else if(row['HasSubApplnDue'] == true) {
            actions.push({
                'label': 'Submit Sub Application',
                'iconName': 'utility:record_create',
                'name': 'sub'
            });
        }
        doneCallback(actions);
    }*/

    async handleRowAction(event) {
        const label = event.target.name
        const recId = event.currentTarget.dataset.applnId
        let row = this.applnData.filter(val => val.Identifier == recId)[0]
        console.log('row '+JSON.stringify(row));
        if(label == 'sub') {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: (row.Role == 'Authorized Person (Entity)' ? 'Authorized_Entity_Sub_Application__c' : (row.Role == 'Authorized Person (Individual)' ? 'Authorized_Individual_Sub_Application__c' : (row.Role == 'Compliance Lawyer' ? 'Compliance_Lawyer_Sub_Application__c' : (row.Role == 'Designated Principal' ? 'Designated_Principal_Sub_Application__c' : ''))))
                },
                state: {
                    c__applnId : row.ApplnId
                }
            });
        }
        if(label == 'resume') {
            window.location.href = row.ResumeURL;
        }
        if(label == 'paynow') {
            console.log('name 2 '+row.ApplnId);
            let _this = this
            const result = await paymentModal.open({
                size: 'large',
                description: '',
                payMode: 'paynow',
                onconfirm: (e) => {
                    e.stopPropagation()
                    _this.showPaymentRedirect = true
                    console.log('name 3 '+_this.showPaymentRedirect)
                    getjBillingPaymentWebPage({
                        applnId : row.ApplnId
                    }).then(result => {
                        console.log('jBilling Order URL '+JSON.stringify(result))
                        if(result.success == true) {
                            window.location.href = result.paymentURL
                        }
                    })
                }
            })
            /*this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Payment_Checkout__c"
                    //name: "Payment__c"
                },
                state: {
                    c__applnId : row['ApplnId']
                }
            });*/
        }
    }
    
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail
        const cloneData = [...this.allApplnData]
        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1))
        this.allApplnData = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }

    updatePaginatorHandler(event) {
        this.applnData = [...event.detail.records]
        this.showSpinner = false
    }
}