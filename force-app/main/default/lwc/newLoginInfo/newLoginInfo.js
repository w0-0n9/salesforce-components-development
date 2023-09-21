import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import EmailName from '@salesforce/schema/User.Email';

const fields = [Name, RoleName, ProfileName, EmailName];

export default class NewLoginInfo extends LightningElement {
    

    userId = Id;
    userName;
    userRoleName;
    userProfileName;
    userEmail = EmailName;

    @wire(getRecord, { recordId: Id, fields})
    
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
            }
            if (data.fields.UserRole.value != null) {
                this.userRoleName = data.fields.UserRole.value.fields.Name.value;
            }
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
            if (data.fields.Email.value != null) {
                this.userEmail = data.fields.Email.value;
            }
        }
    }
}