import { LightningElement, track, wire } from 'lwc';
import getYoutubeURL from '@salesforce/apex/YoutubeURLController.getYoutubeURL';

export default class SalesforceYoutube extends LightningElement {
    @wire(getYoutubeURL) youtubeURL;
}