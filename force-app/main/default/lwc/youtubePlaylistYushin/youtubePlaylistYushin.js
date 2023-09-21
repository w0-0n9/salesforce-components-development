import { LightningElement } from 'lwc';

export default class YoutubePlaylistYushin extends LightningElement {
    videoIds = ['6LEYPTku1bo', 'UNWduQ3VH4M', '_Gya205BkkE']
    currentIndex = 0;
    player;
    variable;

    renderedCallback() {
        this.loadVideo();
    }

    loadVideo() {
        const currentVideoId = this.videoIds[this.currentIndex];

        const iframe = document.createElement('iframe');
        iframe.setAttribute('width', '100%');
        iframe.setAttribute('height', '500');
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('allow', 'autoplay; encrypted-media');
        iframe.src = `https://www.youtube.com/embed/${currentVideoId}?autoplay=1&mute=1&loop=1`;

        const container = this.template.querySelector('.player-container');

        // Remove any previously appended iframes before adding the new one
        while (container.firstChild) {
            container.removeChild(container.firstChild);
        }
        container.appendChild(iframe);

        // this.currentIndex = (this.currentIndex + 1) % this.videoIds.length;
        // // Listen to the 'ended' event to load the next video
        // iframe.addEventListener('ended', () => {
        //     this.loadVideo();
        // });
    }
}