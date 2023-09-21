import { LightningElement, track } from 'lwc';
import callNaverNewsAPI from '@salesforce/apex/NaverNewsController.callNaverNewsAPI';

export default class NaverNewsYushin extends LightningElement {
    @track searchTerm = '삼성 에스디에스';
    @track newsList;

    connectedCallback() {
        this.searchNews();
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    searchNews() {
        if (this.searchTerm) {
            callNaverNewsAPI({ searchQuery: this.searchTerm })
                .then((result) => {
                    const parsedResult = JSON.parse(result);
                    console.log(parsedResult);
                    if (parsedResult.items) {
                        this.newsList = this.removeHTMLTags(parsedResult.items);

                        this.newsList.forEach((newsItem) => {
                            if (newsItem.pubDate) {
                                newsItem.pubDate = this.formatDate(newsItem.pubDate);
                            }
                        });
                    } else {
                        console.error('Error fetching news: ', parsedResult);
                    }
                })
                .catch((error) => {
                    console.error('Error fetching news: ', error);
                });
        }
    }

    removeHTMLTags(newsItems) {
        const removeHTMLTags = (str) => str.replace(/<[^>]+>/g, '');
        const removeSpecialCharacters = (str) => str.replace(/&apos;/g, "'");
        const removeQuot = (str) => str.replace(/&quot;/g, "'");
    
        for (let i = 0; i < newsItems.length; i++) {
            newsItems[i].title = removeHTMLTags(newsItems[i].title);
            newsItems[i].title = removeSpecialCharacters(newsItems[i].title);
            newsItems[i].title = removeQuot(newsItems[i].title);
        }
        return newsItems;
    }

    formatDate(date) {
        const dateParts = date.split(' ');
        return `${dateParts[0]} ${dateParts[1]} ${dateParts[2]} ${dateParts[3]}`;
    }
}