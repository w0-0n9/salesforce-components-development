import { LightningElement, track, wire, api } from 'lwc';
import getHomeVideo from '@salesforce/apex/HomeVideoController.getHomeVideo';
import getHomeVideoURL from '@salesforce/apex/HomeVideoController.getHomeVideoURL';


export default class videoPlayer extends LightningElement {

    @wire(getHomeVideoURL) homeVideoURL;

}