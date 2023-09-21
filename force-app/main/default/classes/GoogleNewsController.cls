public without sharing class GoogleNewsController {
    private static final String URL_BASE = 'https://news.google.com/rss/search';
    private static final String DEFAULT_COUNTRY = 'US';
    private static final Map<String, Integer> MONTHS = new Map<String, Integer> {
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
        'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
    };
       
    private static final Map<String, String> COUNTRY_LIST = new Map<String, String> {
    	'AR' => 'hl=es-419&gl=AR&ceid=AR:es-419', // Argentina
        'AU‎' => 'hl=en-AU&gl=AU&ceid=AU:en',      // Australia
        'AT‎' => 'hl=de&gl=AT&ceid=AT:de',         // Austria
        //'BE' => 'hl=nl&gl=BE&ceid=BE:nl',         // Belgium [Dutch]
        'BE' => 'hl=fr&gl=BE&ceid=BE:fr',         // Belgium [French]
        'BR' => 'hl=pt-BR&gl=BR&ceid=BR:pt-419',  // Brazil
        'CA' => 'hl=en-CA&gl=CA&ceid=CA:en',      // Canada [English]
        //'CA' => 'hl=fr-CA&gl=CA&ceid=CA:fr',      // Canada [French]
        'CN‎' => 'hl=zh-CN&gl=CN&ceid=CN:zh-CN',   // China
        'FR' => 'hl=fr&gl=FR&ceid=FR:fr',         // France
        'DE‎' => 'hl=de&gl=DE&ceid=DE:de',         // Germany
        'GR‎' => 'hl=el&gl=GR&ceid=GR:el',         // Greece
        'HK‎' => 'hl=zh-HK&gl=HK&ceid=HK:zh-Hant', // Hong Kong
        //'IN' => 'hl=hi&gl=IN&ceid=IN:hi',         // India [Hindi]
        'IN' => 'hl=en-IN&gl=IN&ceid=IN:en',      // India‎ [English]
        'IT' => 'hl=it&gl=IT&ceid=IT:it',         // Italy
        'JP' => 'hl=ja&gl=JP&ceid=JP:ja',         // Japan
        'KR' => 'hl=ko&gl=KR&ceid=KR:ko',         // Korea
        'MY‎' => 'hl=en-MY&gl=MY&ceid=MY:en',      // Malaysia
        'NL‎' => 'hl=nl&gl=NL&ceid=NL:nl',         // Netherlands
        'NZ' => 'hl=en-NZ&gl=NZ&ceid=NZ:en',      // New Zealand
        'PH‎' => 'hl=en&gl=PH&ceid=PH:en',         // Philippines
        'PT‎' => 'hl=pt-PT&gl=PT&ceid=PT:pt-PT',   // Portugal
        'RU‎' => 'hl=ru&gl=RU&ceid=RU:ru',         // Russia
        'SG‎' => 'hl=en-SG&gl=SG&ceid=SG:en',      // Singapore
        'TW‎' => 'hl=zh-TW&gl=TW&ceid=TW:zh-TW',   // Taiwan
        'TH' => 'hl=th&gl=TH&ceid=TH:th',         // Thailand
        'TR‎' => 'hl=tr&gl=TR&ceid=TR:tr',         // Turkey
        'GB' => 'hl=en-GB&gl=GB&ceid=GB:en',      // United
        'US' => 'hl=en-US&gl=US&ceid=US:en',      // United States [English]
        //'US' => 'hl=es-419&gl=US&ceid=US:es-419', // United States [Spanish]
        'VN' => 'hl=vi&gl=VN&ceid=VN:vi'          // Vietnam
	};

    public static Datetime fromRFC1123(String x) {
        String[] dateParts = x.split('[\\s:]');
        Integer year = Integer.valueOf(dateParts[3]);
        Integer month = MONTHS.get(dateParts[2]);
        Integer day = Integer.valueOf(dateParts[1]);
        Integer hour = Integer.valueOf(dateParts[4]);
        Integer minute = Integer.valueOf(dateParts[5]);
        Integer second = Integer.valueOf(dateParts[6]);
        return Datetime.newInstanceGmt(year, month, day, hour, minute, second);
    }
    
    @AuraEnabled
    public static List<GoogleNews> getContents4Account(Id accountId) {
        Account acc;        
        try {
            acc = [Select Name, NewsKeyword__c, BillingCountryCode from Account where ID = :accountId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }

        String urlSuffix = '';
        if(acc.BillingCountryCode != null){
            urlSuffix = COUNTRY_LIST.get(acc.BillingCountryCode);
        } else {
            urlSuffix = COUNTRY_LIST.get(DEFAULT_COUNTRY);
        }
        String companyName = '';
        if(acc.NewsKeyword__c != null){
            String keywords = acc.NewsKeyword__c;
            if(keywords.contains(';')){
                String[] words = keywords.split(';');
                for(String word : words){
                    companyName += '"' + word.trim() + '"|';
                }
                companyName = companyName.substring(0, companyName.length() - 1);
            } else companyName = '"' + keywords + '"';
        } else{
            companyName = '"' + acc.Name + '"';
        }

        String queryKeyword = EncodingUtil.urlEncode(companyName, 'UTF-8');
        String url = URL_BASE + '?q=' + queryKeyword + '&' + urlSuffix;

        return getContents(url);
    }

    @AuraEnabled
    public static List<GoogleNews> getContents4Home() {
        String searchUrl = '';
        User u = [SELECT Country, CountryCode FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        //system.debug(u);
        String urlSuffix = '';
        if(u.CountryCode != null){
            //String countryCode = getCountryCode(u.Country);
            urlSuffix = COUNTRY_LIST.get(u.CountryCode);
        } else {
            urlSuffix = COUNTRY_LIST.get(DEFAULT_COUNTRY);
        }
        list<GoogleNewsKeyword__c> keyObjs = [SELECT Name FROM GoogleNewsKeyword__c WHERE OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 10];
        String keyword = '';
        String commonKey = Label.GOOGLENEWS_KEYWORD;
        if(commonKey.trim().length() > 0) keyword = parseCommonKeyword(commonKey.trim());
        if(!keyObjs.isEmpty()){
            keyword += keyword.length() > 0 ? '|' : '';
            for(GoogleNewsKeyword__c obj : keyObjs){
                keyword += '"' + obj.Name.trim() + '"|';
            }
            keyword = keyword.substring(0, keyword.length() - 1);
        }

        String queryKeyword = EncodingUtil.urlEncode(keyword, 'UTF-8');
        searchUrl = URL_BASE + '?q=' + queryKeyword + '&' + urlSuffix;
        System.debug(queryKeyword + ' ' + keyword);
        System.debug(searchUrl);
        //searchUrl = URL_BASE + '?q=' + EncodingUtil.urlEncode('삼성 SDS|삼성|현대|CJ|효성|만도|농심|아모레퍼시픽|두산', 'UTF-8') + '&hl=ko&gl=KR&ceid=KR:ko'; // 시연용...
        return getContents(searchUrl);
    }

    @TestVisible
    private static String parseCommonKeyword(String keywords){
        String searchKeys = '';
        if(keywords.contains(';')){
            String[] words = keywords.split(';');
            for(String word : words){
                searchKeys += '"' + word + '"|';
            }
            searchKeys = searchKeys.substring(0, searchKeys.length() - 1);
        } else searchKeys = '"' + keywords + '"';
        return searchKeys;
    }

    public static List<GoogleNews> getContents(String searchUrl) {
        set<String> titleSet = new set<String>();

        system.debug('google new url -> ' + searchUrl);
        HttpResponse res = getRss(searchUrl);

        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode rss = doc.getRootElement();
        List<GoogleNews> newsItems = new List<GoogleNews>();

        for(Dom.XMLNode channel : rss.getChildren()) {
            for(Dom.XMLNode child : channel.getChildren()) {
                if(child.getName() == 'item') {
                    GoogleNews item = parseNewsItem(child);
                    String title = item.Title;
                    if(!titleSet.contains(title)){
                        newsItems.add(item);
                        titleSet.add(title);
                    }
                }
                if(newsItems.size() >= 30) break;
            }
        }
        
        GoogleNewsWrapper[] newsList = new GoogleNewsWrapper[0];
        for(GoogleNews news : newsItems){
            Integer asofday = Integer.valueOf(news.AsOfDay.replace('d',''));
            newsList.add(new GoogleNewsWrapper(news, asofday));
        }
        newsList.sort();
        newsItems = new list<GoogleNews>();
        for(GoogleNewsWrapper item : newsList){
            newsItems.add(item.news);
        }
        //if(newsItems.size() > 20){
        //    list<GoogleNews> tmp = new list<GoogleNews>();
        //    for(Integer cnt = 0; cnt < 20; cnt++) tmp.add(newsItems[cnt]);
        //    newsItems = tmp;
        //}
        return newsItems;
    }
    
    private static GoogleNews parseNewsItem(Dom.XMLNode child){
        Pattern imgTagPattern = Pattern.compile('<img\\s[^[src]]*="([^"]*)"[^>]*>');
        Pattern descPattern = Pattern.compile('<a(.*?)>(.*?)<\\/');

        GoogleNews item = new GoogleNews();

        for(Dom.XMLNode childElem : child.getChildren()) {
            String elemName = childElem.getName();
            if(elemName == 'title') {
                item.Title = childElem.getText();
            } else if(elemName == 'link') {
                item.Url = childElem.getText();
            } else if(elemName == 'pubDate') {
                DateTime tmp = fromRFC1123(childElem.getText());
                item.PublishDate = tmp.format('yyyy-MM-dd');
                item.AsOfDay = String.valueOf(Math.abs(system.today().daysBetween(tmp.date())))+'d';
            } else if(elemName == 'source') {
                item.Publisher = childElem.getText();
            } else if(elemName == 'description') {
                Matcher imgUrlMatcher = imgTagPattern.matcher(childElem.getText());
                if(imgUrlMatcher.find()) {
                    item.ImgUrl = imgUrlMatcher.group(1);
                    item.hasImage = true;
                } else {
                    Matcher descMatcher = descPattern.matcher(childElem.getText());
                    if(descMatcher.find()) {
                        item.Description =descMatcher.group(2);
                    }
                }
            } else if(elemName == 'content') {
                if(childElem.getAttribute('medium', '') == 'image') {
                    item.ImgUrl = childElem.getAttribute('url', '');
                    item.hasImage = true;
                }                            
            }
        }                
        
        if(item.Publisher != null) item.Title = item.Title.replace('- '+item.Publisher, '');
        return item;
    }

    private static HttpResponse getRss(String url) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        Integer statusCode = res.getStatusCode();
        if(statusCode == 302 || statusCode == 301 || statusCode == 304) {
            String redirectUrl = res.getHeader('Location');
            res = getRss(redirectUrl);
        }
        return res;
    }

    @AuraEnabled
    public static list<String> getKeywords(){
        list<String> keywords = new list<String>();
        try {
            list<GoogleNewsKeyword__c> lgnk = [SELECT Id, Name FROM GoogleNewsKeyword__c WHERE OwnerId = :UserInfo.getUserId()];
            if(!lgnk.isEmpty()){
                for(GoogleNewsKeyword__c gnk : lgnk){
                    keywords.add(gnk.Name);
                }
            }
            return keywords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveKeywords(list<String> keywords){
        try {
            list<GoogleNewsKeyword__c> lgnk = [SELECT Id, Name FROM GoogleNewsKeyword__c WHERE OwnerId = :UserInfo.getUserId()];
            list<GoogleNewsKeyword__c> lupd = new list<GoogleNewsKeyword__c>();
            if(!lgnk.isEmpty()) delete lgnk;
            if(keywords != null && keywords.size() > 0){
                for(String keyword : keywords){
                    lupd.add(new GoogleNewsKeyword__c(Name = keyword));
                }
            }
            if(!lupd.isEmpty()) insert lupd;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean shareNews(String shareRichText, String shareUrl, String shareUrlTitle){
        try {
            FeedItem post = new FeedItem(isRichText = true);
            post.Body = shareRichText;
            post.ParentId = UserInfo.getUserId();
            post.Title = shareUrlTitle;
            post.LinkUrl = shareUrl;

            insert post;
            return true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class GoogleNewsWrapper implements Comparable {
        public GoogleNews   news;
        public Integer      order;
        
        public GoogleNewsWrapper(GoogleNews news, Integer order){
            this.news = news;
            this.order = order;
        }
        public Integer compareTo(Object other){
            return order - ((GoogleNewsWrapper) other).order;
        }
    }

    class GoogleNews {
        @AuraEnabled
        public String   Title           { get; set; }
        @AuraEnabled
        public String   Description     { get; set; }
        @AuraEnabled
        public String   Url             { get; set; }
        @AuraEnabled
        public String   PublishDate     { get; set; }
        @AuraEnabled
        public String   AsOfDay         { get; set; }
        @AuraEnabled
        public String   Publisher       { get; set; }
        @AuraEnabled
        public String   ImgUrl          { get; set; }
        @AuraEnabled
        public Boolean  hasImage        { get; set; }

        public GoogleNews(){
            this.hasImage = false;
        }

    }
}