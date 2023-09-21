import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';



const Fields = [
    'Account.eivalue1__c',
    'Account.eivalue2__c',
    'Account.eivalue3__c',
    'Account.eivalue4__c',
    'Contact.eivalue1__c',
    'Contact.eivalue2__c',
    'Contact.eivalue3__c',
    'Contact.eivalue4__c',
];




export default class easyinsights extends LightningElement {

@api title;
@api icon;

@api metric1_title;
@api metric1_value;
@api metric1_cb;

@api metric2_title;
@api metric2_value;
@api metric2_cb;

@api metric3_title;
@api metric3_value;
@api metric3_cb;


@api metric4_title;
@api metric4_value;
@api metric4_cb;


@api recordId;
@track record;

    @wire(getRecord, {recordId: '$recordId', optionalFields: Fields})
    record;

    get eimetric1()
    {
        var acc = getFieldValue(this.record.data, 'Account.eivalue1__c');
        var con = getFieldValue(this.record.data, 'Contact.eivalue1__c');

        if (acc != null)
            return acc;
        else
        if (con)
            return con;
    }

    get eimetric2()
    {
        var acc = getFieldValue(this.record.data, 'Account.eivalue2__c');
        var con = getFieldValue(this.record.data, 'Contact.eivalue2__c');

        if (acc != null)
            return acc;
        else
        if (con)
            return con;
    }

    get eimetric3()
    {
        var acc = getFieldValue(this.record.data, 'Account.eivalue3__c');
        var con = getFieldValue(this.record.data, 'Contact.eivalue3__c');

        if (acc != null)
            return acc;
        else
        if (con)
            return con;
    }

    get eimetric4()
    {
        var acc = getFieldValue(this.record.data, 'Account.eivalue4__c');
        var con = getFieldValue(this.record.data, 'Contact.eivalue4__c');

        if (acc != null)
            return acc;
        else
        if (con)
            return con;
    }


}