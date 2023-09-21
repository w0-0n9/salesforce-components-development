global with sharing class HomeCalendarController {
    @AuraEnabled
    global static List<String> monthSetting(){
        List<String> rtnList = new List<String>();
        for(Integer i = 1; i <= 12; i++){
            if(UserInfo.getLanguage() != 'ko'){
                DateTime dt = DateTime.newInstance(2015, i, 5);
                rtnList.add(dt.format('MMMM'));
            }else{
                rtnList.add(i + '월');
            }
        }
        return rtnList;
    }

    /**
    * @description 표시될 현재 년/월 달력
    * @author gilhwan.ahn@hanwha.com | 2020. 5. 14. 
    * @param sYear  검색년도
    * @param sMonth 검색월
    * @return map<String, Object> 
    **/
    @AuraEnabled
    global static map<String, Object> getMyActivities(String sYear, String sMonth, String jsonObj, Boolean myTeam){
        ObjCheck objCheck = (ObjCheck)JSON.deserialize(jsonObj, ObjCheck.class);

        List<User> myTeamList = new List<User>();
        if(myTeam) myTeamList = RoleUtil.getAllSubordinates(UserInfo.getUserId());
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        myTeamList.add(u);

        // 데이터를 적재할 Map
        map<String, Object> mActivity     = new map<String, Object>();
        map<String, Object> mEvent        = new map<String, Object>();
        map<String, Object> mTask         = new map<String, Object>();
        map<String, Object> mAccPlan      = new map<String, Object>();
        map<String, Object> mOpptActivity = new map<String, Object>();

        // 검색 기간 설정
        TimeZone tz     = UserInfo.getTimeZone();
        Integer nYear   = Integer.valueOf(sYear);
        Integer nMonth  = Integer.valueOf(sMonth);
        Date startDate  = Date.newInstance(nYear, nMonth, 1);
        Date endDate    = Date.newInstance(nYear, nMonth, Date.daysInMonth(nYear, nMonth));
        Date today      = Date.today();
        Date yesterday  = Date.today().addDays(-1);

        // 활동일지
        List<Event> levent = new List<Event>();
        String queryStr_levent = 'SELECT ActivityDate FROM Event WHERE ActivityDate >= :startdate AND ActivityDate <= :enddate';
        queryStr_levent += ' AND OwnerId =: myTeamList';
        queryStr_levent += ' LIMIT 100';

        if(objCheck.event) levent = Database.query(queryStr_levent);
        /*
        if(objCheck.event){
            levent = [SELECT ActivityDate
                        FROM Event 
                       WHERE ActivityDate >= :startdate
                         AND ActivityDate <= :enddate
                       LIMIT 100];
        }
        */

        // to-do
        List<Task> ltask = new List<Task>();
        String queryStr_ltask = 'SELECT ActivityDate FROM Task WHERE ActivityDate >= :startdate AND ActivityDate <= :enddate';
        queryStr_ltask += ' AND OwnerId =: myTeamList';
        queryStr_ltask += ' LIMIT 100';

        if(objCheck.Task) ltask = Database.query(queryStr_ltask);

        /*
        if(objCheck.Task){
            ltask = [SELECT ActivityDate
                       FROM Task 
                      WHERE ActivityDate >= :startdate
                        AND ActivityDate <= :enddate
                      LIMIT 100];
        }
        */

        /**
         * seonju.jin@dkbmc.com | 2020-11-15 
         * Account Plan, Opportunity Activity 추가
         
        //Account Plan
        List<AccountPlan__c> lacctPlan = new List<AccountPlan__c>();
        String queryStr_lacctPlan = 'SELECT StartDateTime__c FROM AccountPlan__c WHERE StartDateTime__c >= :startDate AND StartDateTime__c <= :endDate';
        queryStr_lacctPlan += ' AND OwnerId =: myTeamList';
        queryStr_lacctPlan += ' LIMIT 100';

        if(objCheck.acctPlan) lacctPlan = Database.query(queryStr_lacctPlan);
        */
        
        /*
        if(objCheck.acctPlan){
            lacctPlan = [SELECT StartDateTime__c
                           FROM AccountPlan__c
                          WHERE StartDateTime__c >= :startDate
                            AND StartDateTime__c <= :endDate
                          LIMIT 100];
        }
        */
            
        //Opportunity Activity - past
        /*
        List<AggregateResult> pastOpptActivityList = new List<AggregateResult>();
        String queryStr_pastOpptAct = 'SELECT StartDate__c, EndDate__c, DueDate__c FROM Opportunity_Activity__c WHERE EndDate__c >= :startDate AND EndDate__c <= :yesterday';
        queryStr_pastOpptAct += ' AND WhatId__r.OwnerId =: myTeamList';
        queryStr_pastOpptAct += ' GROUP BY StartDate__c, EndDate__c, DueDate__c';
        queryStr_pastOpptAct += ' LIMIT 100';

        if(objCheck.opptyAct) pastOpptActivityList = Database.query(queryStr_pastOpptAct);


        if(objCheck.opptyAct){
            pastOpptActivityList = [SELECT StartDate__c, EndDate__c, DueDate__c
                                      FROM Opportunity_Activity__c
                                     WHERE EndDate__c >= :startDate
                                       AND EndDate__c <= :yesterday
                                  GROUP BY StartDate__c, EndDate__c, DueDate__c
                                     LIMIT 100];
        }
        */

        //Opportunity Activity - future
        /*
        List<AggregateResult> futureOpptActivityList = new List<AggregateResult>();
        String queryStr_futureOpptAct = 'SELECT StartDate__c, EndDate__c, DueDate__c FROM Opportunity_Activity__c WHERE ((StartDate__c >= :today AND StartDate__c <= :endDate) OR (DueDate__c >= :today AND DueDate__c <= :endDate))';
        queryStr_futureOpptAct += ' AND WhatId__r.OwnerId =: myTeamList';
        queryStr_futureOpptAct += ' GROUP BY StartDate__c, EndDate__c, DueDate__c';
        queryStr_futureOpptAct += ' LIMIT 100';

        if(objCheck.opptyAct) futureOpptActivityList = Database.query(queryStr_futureOpptAct);


        if(objCheck.opptyAct){
            futureOpptActivityList = [SELECT StartDate__c, EndDate__c, DueDate__c
                                        FROM Opportunity_Activity__c
                                       WHERE WhatId__r.OwnerId =: myTeamList
                                         AND ((StartDate__c >= :today AND StartDate__c <= :endDate) OR (DueDate__c >= :today AND DueDate__c <= :endDate))
                                    GROUP BY StartDate__c, EndDate__c, DueDate__c
                                       LIMIT 100];
        }
        */

        // 활동일지
        if(!levent.isEmpty()){
            for(Event obj : levent){
                DateTime dt = obj.ActivityDate;
                String evt  = dt.format('yyyy-MM-dd', tz.getId());
                
                // Record Type 별 적재
                Set<String> evtSet = (Set<String>)mEvent.get(evt);
                if(evtSet == null) evtSet = new Set<String>();
                evtSet.Add('Event');
                mEvent.put(evt, evtSet);
            }
        }

        // to-do
        if(!ltask.isEmpty()){
            for(Task obj : ltask){
                DateTime dt = obj.ActivityDate;
                String tsk  = dt.format('yyyy-MM-dd', tz.getId());

                Set<String> tskSet = (Set<String>)mTask.get(tsk);
                if(tskSet == null) tskSet = new Set<String>();
                tskSet.add('Task');

                mTask.put(tsk, tskSet);
            }
        }

        /*
        // Account Plan
        if(!lacctPlan.isEmpty()){
            for(AccountPlan__c obj : lacctPlan){
                DateTime dt = obj.StartDateTime__c;
                String plan = dt.format('yyyy-MM-dd', tz.getId());

                Set<String> accPlanSet = (Set<String>) mAccPlan.get(plan);
                if(accPlanSet == null) accPlanSet = new Set<String>();
                accPlanSet.add('AccountPlan');

                mAccPlan.put(plan, accPlanSet);
            }
        }
        */

        /*
        // Opportunity Activity - past
        if(!pastOpptActivityList.isEmpty()){
            for(AggregateResult obj : pastOpptActivityList){
                DateTime dt = (DateTime) obj.get('EndDate__c');
                String opptAct = dt.format('yyyy-MM-dd', tz.getId());

                Set<String> opptActSet = (Set<String>) mOpptActivity.get(opptAct);
                if(opptActSet == null) opptActSet = new Set<String>();
                opptActSet.add('Opportunity Activity');

                mOpptActivity.put(opptAct, opptActSet);
            }
        }

        // Opportunity Activity - future
        if(!futureOpptActivityList.isEmpty()){
            for(AggregateResult obj : futureOpptActivityList){
                DateTime dt = (DateTime) obj.get('StartDate__c') == null ? (DateTime) obj.get('DueDate__c') : (DateTime) obj.get('StartDate__c');
                String opptAct = dt.format('yyyy-MM-dd', tz.getId());

                Set<String> opptActSet = (Set<String>) mOpptActivity.get(opptAct);
                if(opptActSet == null) opptActSet = new Set<String>();
                opptActSet.add('Opportunity Activity');

                mOpptActivity.put(opptAct, opptActSet);
            }
        }
        */
        
        mActivity.put('event', mEvent);
        mActivity.put('task', mTask);
        mActivity.put('accPlan', mAccPlan);
        mActivity.put('opptActivity', mOpptActivity);

        return mActivity;
    }

    /**
    * @description 선택한 일자의 검색할 데이터
    * @author gilhwan.ahn@hanwha.com | 2020. 5. 14. 
    * @param targetDate 
    * @return list<HomeActivity> 
    **/
    @AuraEnabled
    global static Map<String, String> getTodayActivities(String targetDate, String jsonObj, Boolean myTeam){
        Map<String, String> rtnMap = new Map<String, String>();
        ObjCheck objCheck = (ObjCheck)JSON.deserialize(jsonObj, ObjCheck.class);
        list<HomeActivity> lActivity = new list<HomeActivity>();
        list<String> dates = targetDate.split('-');

        Date activityDate = Date.newInstance(Integer.valueOf(dates[0]), Integer.valueOf(dates[1]), Integer.valueOf(dates[2]));
        String formattedDateStr = DateTime.newInstance(activityDate.year(), activityDate.month(), activityDate.day()).format(Utils.getUserDateFormat());
        rtnMap.put('Today', formattedDateStr);
        Date tomorrowDate = activityDate.addDays(1);
        Date today        = Date.today();

        List<User> myTeamList = new List<User>();
        if(myTeam) myTeamList = RoleUtil.getAllSubordinates(UserInfo.getUserId());
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        myTeamList.add(u);

        list<Event> levent = new list<Event>();
        String queryStr_levent = 'SELECT Id, ActivityDate, Subject, What.Name, OwnerId, Owner.Name FROM Event WHERE DAY_ONLY(convertTimezone(StartDateTime)) = :activityDate';
        queryStr_levent += ' AND OwnerId =: myTeamList';
        queryStr_levent += ' LIMIT 100';

        if(objCheck.event) levent = Database.query(queryStr_levent);

        /*
        if(objCheck.event){
            levent = [SELECT Id, ActivityDate, Subject, What.Name, OwnerId, Owner.Name
                        FROM Event 
                       WHERE DAY_ONLY(convertTimezone(StartDateTime)) = :activityDate
                       LIMIT 100];
                    // WHERE ActivityDate = :activityDate
        }
        */

        list<Task> ltask = new list<Task>();
        String queryStr_ltask = 'SELECT Id, ActivityDate, Subject, What.Name, Status, OwnerId, Owner.Name FROM Task WHERE ActivityDate = :activityDate AND TaskSubtype != \'Email\'';
        queryStr_ltask += ' AND OwnerId =: myTeamList';
        queryStr_ltask += ' LIMIT 100';

        if(objCheck.task) ltask = Database.query(queryStr_ltask);

        /*
        if(objCheck.task){
            ltask = [SELECT Id, ActivityDate, Subject, What.Name, Status, OwnerId, Owner.Name
                       FROM Task 
                      WHERE ActivityDate = :activityDate
                        AND TaskSubtype != 'Email'
                      LIMIT 100];
        }
        */
                            
        /**
         * seonju.jin@dkbmc.com | 2020-11-15 
         * Account Plan, Opportunity Activity 추가
         */
        /*
        list<AccountPlan__c> lacctPlan = new list<AccountPlan__c>();
        String queryStr_lacctPlan = 'SELECT Id, StartDateTime__c, Name, AccountId__c, AccountId__r.Name, OwnerId, Owner.Name FROM AccountPlan__c WHERE StartDateTime__c >: activityDate AND StartDateTime__c <: tomorrowDate';
        queryStr_lacctPlan += ' AND OwnerId =: myTeamList';
        queryStr_lacctPlan += ' LIMIT 100';

        if(objCheck.acctPlan) lacctPlan = Database.query(queryStr_lacctPlan);

        */
            
        /*
        if(objCheck.acctPlan){
            lacctPlan = [SELECT Id, StartDateTime__c, Name, AccountId__c, AccountId__r.Name, OwnerId, Owner.Name
                           FROM AccountPlan__c
                          WHERE StartDateTime__c >: activityDate AND StartDateTime__c <: tomorrowDate
                          LIMIT 100];
        }
        */

        /*
        Map<String, String> oppActNameMap = new Map<String, String>();
        Schema.DescribeFieldResult oppActNameFieldResult = Opportunity_Activity__c.TransactionName__c.getDescribe();
        List<Schema.PicklistEntry> oppActNameList = oppActNameFieldResult.getPicklistValues();
        for (Schema.PicklistEntry oppActName: oppActNameList) {
            oppActNameMap.put(oppActName.getValue(), oppActName.getLabel());
        }
        
        list<Opportunity_Activity__c> lopptAct = new list<Opportunity_Activity__c>();
        if(objCheck.opptyAct){
            String queryStr_lopptAct = 'SELECT Id, StartDate__c, EndDate__c, DueDate__c, Name, WhatId__c, WhatId__r.Name, WhatId__r.OwnerId, WhatId__r.Owner.Name, TransactionName__c FROM Opportunity_Activity__c';
            if(activityDate < today){ // 오늘보다 이전 일자
                queryStr_lopptAct += ' WHERE EndDate__c = :activityDate';
                queryStr_lopptAct += ' AND WhatId__r.OwnerId =: myTeamList';
                queryStr_lopptAct += ' LIMIT 100';

                lopptAct = Database.query(queryStr_lopptAct);

                // Opportunity Activity 내역
                if(!lopptAct.isEmpty()){
                    for(Opportunity_Activity__c obj : lopptAct){
                        HomeActivity t  = new HomeActivity();
                        String TransactionName = oppActNameMap.get(obj.TransactionName__c);
                        t.id            = obj.Id;
                        // t.type           = 'Oppty Activity';
                        t.realType   = 'Oppty';
                        t.type          = Label.CALEANDER_LAB_OPPTYACTIVITY2; // Oppty Activity
                        t.activeDate    = String.valueOf(obj.EndDate__c);
                        t.subject       = TransactionName;
                        t.related       = obj.WhatId__c != null ? obj.WhatId__r.Name : '';
                        t.relatedId     = obj.WhatId__c != null ? obj.WhatId__c +''  : '';
                        t.ownerName     = obj.WhatId__r.Owner.Name;
                        
                        lActivity.add(t);
                    }
                }
            }else{ // 오늘포함 오늘 이후 일자
                queryStr_lopptAct += ' WHERE (StartDate__c = :activityDate OR DueDate__c =: activityDate)';
                queryStr_lopptAct += ' AND WhatId__r.OwnerId =: myTeamList';
                queryStr_lopptAct += ' LIMIT 100';

                lopptAct = Database.query(queryStr_lopptAct);

                // Opportunity Activity 내역
                if(!lopptAct.isEmpty()){
                    for(Opportunity_Activity__c obj : lopptAct){
                        HomeActivity t  = new HomeActivity();
                        String TransactionName = oppActNameMap.get(obj.TransactionName__c);
                        t.id            = obj.Id;
                        // t.type           = 'Oppty Activity';
                        t.realType   = 'Oppty';
                        t.type          = Label.CALEANDER_LAB_OPPTYACTIVITY2; // Oppty Activity
                        t.activeDate    = String.valueOf(obj.StartDate__c == null ? obj.DueDate__c : obj.StartDate__c);
                        t.subject       = TransactionName;
                        t.related       = obj.WhatId__c != null ? obj.WhatId__r.Name : '';
                        t.relatedId     = obj.WhatId__c != null ? obj.WhatId__c +''  : '';
                        t.ownerName     = obj.WhatId__r.Owner.Name;
                        
                        lActivity.add(t);
                    }
                } 
            }
        }

        */

        Map<String, String> typeMap  = new Map<String, String>{
            'Event' => 'Event',
            'Task'  => 'Task'
        };      

        // 나의 활동내역
        if(!levent.isEmpty()){
            for(Event obj : levent){
                HomeActivity a = new HomeActivity();
                a.id           = obj.Id;
                // a.type          = 'Event';
                a.realType   = 'Event';
                a.type         = Label.CALEANDER_LAB_EVENT;
                a.activeDate   = String.valueOf(obj.ActivityDate);
                a.subject      = obj.Subject;
                a.related      = obj.WhatId != null ? obj.What.Name  : '';
                a.relatedId    = obj.WhatId != null ? obj.WhatId +'' : '';
                a.ownerName    = obj.Owner.Name;
                lActivity.add(a);
            }
        }

        // to-do 내역존재
        if(!ltask.isEmpty()){
            for(Task obj : ltask){
                HomeActivity t  = new HomeActivity();
                t.id            = obj.Id;
                // t.type           = 'Task';
                t.realType   = 'Task';
                t.type          = Label.CALEANDER_LAB_TASK; // Task
                t.activeDate    = String.valueOf(obj.ActivityDate);
                t.subject       = obj.Subject;
                t.related       = obj.WhatId != null ? obj.What.Name  : '';
                t.relatedId     = obj.WhatId != null ? obj.WhatId +'' : '';
                t.remark        = obj.Status;
                t.ownerName     = obj.Owner.Name;

                lActivity.add(t);
            }
        }

        /*
        // Account Plan 내역
        if(!lacctPlan.isEmpty()){
            TimeZone tz     = UserInfo.getTimeZone();
            for(AccountPlan__c obj : lacctPlan){
                String dt = (obj.StartDateTime__c).format('yyyy-MM-dd', tz.getId());
                HomeActivity t  = new HomeActivity();
                t.id            = obj.Id;
                // t.type           = 'Acct Plan';
                t.realType   = 'Acct';
                t.type          = Label.CALEANDER_LAB_ACCPLAN; // Acct Plan
                t.activeDate    = dt;
                t.subject       = obj.Name;
                t.related       = obj.AccountId__c != null ? obj.AccountId__r.Name : '';
                t.relatedId     = obj.AccountId__c != null ? obj.AccountId__c +''  : '';
                t.ownerName     = obj.Owner.Name;

                lActivity.add(t);
            }
        }
        */
        
        /*
        Map<String, String> oppActNameMap = new Map<String, String>();
        Schema.DescribeFieldResult oppActNameFieldResult = Opportunity_Activity__c.TransactionName__c.getDescribe();
        List<Schema.PicklistEntry> oppActNameList = oppActNameFieldResult.getPicklistValues();
        for (Schema.PicklistEntry oppActName: oppActNameList) {
            oppActNameMap.put(oppActName.getValue(),oppActName.getLabel());
        }
        
        // Opportunity Activity 내역
        if(!lopptAct.isEmpty()){
            for(Opportunity_Activity__c obj: lopptAct){
                HomeActivity t  = new HomeActivity();
                String TransactionName = oppActNameMap.get(obj.TransactionName__c);
                t.id            = obj.Id;
                t.type          = 'Oppty Activity';
                t.activeDate    = String.valueOf(obj.StartDate__c);
                t.subject       = TransactionName;
                t.related       = obj.WhatId__c != null ? obj.WhatId__r.Name : '';
                t.relatedId     = obj.WhatId__c != null ? obj.WhatId__c +''  : '';
                t.ownerName     = obj.WhatId__r.Owner.Name;
                
                lActivity.add(t);
            }
        }
        */

        rtnMap.put('Activity', JSON.serialize(lActivity));
        return rtnMap;
    }

    global class HomeActivity {
        @AuraEnabled
        global String id        {get; set;} // 레코드 id
        @AuraEnabled
        global String realType      {get; set;} // 유형(코드용)
        @AuraEnabled
        global String type      {get; set;} // 유형(화면표시용)
        @AuraEnabled
        global String activeDate{get; set;} // 활동일자
        @AuraEnabled
        global String rdType    {get; set;} // event Record Type
        @AuraEnabled
        global String subject   {get; set;} // 제목
        @AuraEnabled
        global String related   {get; set;} // 관련 목록
        @AuraEnabled
        global String relatedId {get; set;} // 관련 목록 id
        @AuraEnabled
        global String remark    {get; set;} // 비고
        @AuraEnabled
        global String ownerName {get; set;} // 소유자
    }

    global class ObjCheck{
        @AuraEnabled
        global Boolean event {get; set;} // Event
        @AuraEnabled
        global Boolean task {get; set;} // Task
        @AuraEnabled
        global Boolean acctPlan {get; set;} // Account Plan
        @AuraEnabled
        global Boolean opptyAct {get; set;} // Opportunity Activity
    }
}