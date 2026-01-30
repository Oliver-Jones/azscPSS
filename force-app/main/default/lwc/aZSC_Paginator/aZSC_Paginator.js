import { LightningElement, api } from 'lwc';
export default class AZSC_Paginator extends LightningElement {
    @api recordSize = "5";
    currentPage = 1;
    totalRecords;
    totalPage = 0;
    get records(){
        return this.visibleRecords;
    }
    @api 
    set records(data){
        if(data){
            this.totalRecords = data;
            this.recordSize = Number(this.recordSize)
            this.currentPage = 1;
            this.totalPage = Math.ceil(data.length/this.recordSize);
            this.updateRecords();
        }
    }
    connectedCallback() {
        console.log('Here Pagination...');
    }
    get disablePrevious(){ 
        return this.currentPage <= 1;
    }
    get disableNext(){ 
        return this.currentPage >= this.totalPage;
    }
    previousHandler(){ 
        if( this.currentPage > 1 ){
            this.currentPage = this.currentPage - 1;
            this.updateRecords();
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1;
            this.updateRecords();
        }
    }
    updateRecords(){ 
        console.log(this.currentPage);
        const start = (this.currentPage - 1)*this.recordSize;
        const end = this.recordSize*this.currentPage;
        this.visibleRecords = this.totalRecords.slice(start, end);
        this.dispatchEvent(new CustomEvent('update',{ detail:{ records: this.visibleRecords } }));
    }
}