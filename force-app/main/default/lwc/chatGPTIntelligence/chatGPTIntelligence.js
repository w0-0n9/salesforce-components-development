import { LightningElement, api, track } from 'lwc';
import getNonBlankFields from '@salesforce/apex/RecordFieldsFetcher.getNonBlankFields';

export default class ChatGPTIntelligence extends LightningElement {
    @api recordId;
    @track nonBlankFields;
    @track nonBlankFieldsFormatted;
    @track isLoading = true;

    // first method to get executed when LWC component is loaded
    connectedCallback() {
        this.fetchNonBlankFields();
    }

    // Fetch non-blank fields of a record
    fetchNonBlankFields() {
        this.isLoading = true;
        getNonBlankFields({ recordId: this.recordId })
            .then((result) => {
                this.nonBlankFields = result;
                this.nonBlankFieldsFormatted = this.formatFields(result);
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching non-blank fields:', error);
                this.isLoading = false;
            });
    }

    // reusable method to format outcome of getNonBlankFields() method from apex controller
    formatFields(fieldsText) {
        const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
        const nonEmailParts = fieldsText.split(emailRegex);
        const emails = [...fieldsText.matchAll(emailRegex)].map(match => match[0]);
    
        let formattedParts = [];
        for (let i = 0; i < nonEmailParts.length; i++) {
            const nonEmailPart = nonEmailParts[i];
            const nonEmailFragments = nonEmailPart.split('.');
            nonEmailFragments.forEach((fragment, index) => {
                if (index < nonEmailFragments.length - 1) {
                    formattedParts.push({ id: formattedParts.length, text: fragment.trim() + '.' });
                } else {
                    formattedParts.push({ id: formattedParts.length, text: fragment.trim() });
                    if (i < emails.length) {
                        const nextPart = nonEmailParts[i + 1];
                        const emailWithDot = nextPart && nextPart.startsWith(' ') ? emails[i] + '.' : emails[i];
                        formattedParts.push({ id: formattedParts.length, text: emailWithDot });
                    }
                }
            });
        }
    
        return formattedParts;
    }
    
    
    
}