import { LightningElement } from 'lwc';

export default class SalesforceNaverMap extends LightningElement {
    constructor() {
        super();
    // Converted code for script tag 1
    var scriptElement = document.createElement("script");
    scriptElement.setAttribute("type", "text/javascript");
    scriptElement.setAttribute("src", "https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=YOUR_CLIENT_ID&callback=initMap");
    scriptElement.appendChild(document.createTextNode(``));
    document.head.appendChild(scriptElement);

    // Converted code for script tag 2
    var scriptElement = document.createElement("script");
    scriptElement.setAttribute("type", "text/javascript");
    scriptElement.appendChild(document.createTextNode(`
        var map = null;

        function initMap() {
            map = new naver.maps.Map('map', {
                center: new naver.maps.LatLng(37.3595704, 127.105399),
                zoom: 10
            });
        }
    `));
    document.head.appendChild(scriptElement);
    
    // renderedCallback() {
    //     if (!window.naver || !window.naver.maps) {
    //         // Wait for the DOM to be fully loaded before loading the Naver Maps API
    //         window.addEventListener('load', () => {
    //             this.loadNaverMapsAPI();
    //         });
    //     } else {
    //         this.initMap();
    //     }
    // }

    // loadNaverMapsAPI() {
    //     // Create the script element for Naver Maps API
    //     var script = document.createElement('script');
    //     script.type = 'text/javascript';
    //     script.src = 'https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=596ul5qgjk';
    //     script.async = true;

    //     script.onload = () => {
    //         this.initMap();
    //     };

    //     // Add the script element to the document
    //     document.body.appendChild(script);
    // }

    // initMap() {
    //     var container = this.template.querySelector('.map-container');
    //     var options = {
    //         center: new naver.maps.LatLng(37.5666103, 126.9783882), // Seoul, South Korea (Change coordinates accordingly)
    //         zoom: 10 // Adjust the zoom level as needed
    //     };
    //     var map = new naver.maps.Map(container, options);

    //     // Additional script code for the marker
    //     var markerOptions = {
    //         position: new naver.maps.LatLng(37.5112, 127.0981),
    //         map: map
    //     };
    //     var marker = new naver.maps.Marker(markerOptions);
    // }
}
}