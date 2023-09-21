import { LightningElement, api } from 'lwc';

export default class YoutubePlayer extends LightningElement {
    @api videoId

    renderedCallback() {
        if (!this.playerCreated) {
            this.loadYoutubePlayer();
            this.playerCreated = true;
        }
    }

    loadYoutubePlayer() {
        console.log('loadYoutubePlayer!!');
        
        const tag = document.createElement('script');
        //tag.src = 'https://www.youtube.com/iframe_api';
        tag.src = 'https://www.youtube.com/player_api';
        


        const firstScriptTag = document.getElementsByTagName('script')[0];

        console.log('firstScriptTag : '+firstScriptTag);

        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        console.log('loadYoutubePlayer!! player start!!!');
        
        window.onYouTubeIframeAPIReady = () => {

            console.log('loadYoutubePlayer!! onYouTubeIframeAPIReady!!!');

            const player = new window.YT.Player(this.template.querySelector('.player'), {
                height: '390',
                width: '640',
                //videoId: this.videoId,
                videoId: 'UNWduQ3VH4M',
                events: {
                    'onReady': this.onPlayerReady,
                    'onStateChange': this.onPlayerStateChange
                }
            });
        };        
    }

    onPlayerReady(event) {
        event.target.playVideo();
    }

    onPlayerStateChange(event) {
        // Do something when player state changes (e.g. playing, paused, ended, etc.)
        if (event.data == YT.PlayerState.PLAYING && !done) {
            setTimeout(stopVideo, 6000);
            done = true;
        }
    }


}