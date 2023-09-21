/**
 * @description       : 
 * @author            : masterK
 * @group             : 
 * @last modified on  : 07-19-2023
 * @last modified by  : masterK
**/
public class LoginUserInfoController {
    @AuraEnabled
    public static Map<String, String> getLoginUserInfo(){
        Map<String, String> returnMap = new Map<String, String>();
        Map<String, String> mapMonth = new Map<String, String>{
			'Jan' => '01',
			'Feb' => '02',
			'Mar' => '03',
			'Apr' => '04',
			'May' => '05',
			'Jun' => '06',
			'Jul' => '07',
			'Aug' => '08',
			'Sep' => '09',
            'Oct' => '10',
			'Nov' => '11',
			'Dec' => '12'   
		};
                    
		Map<String, String> sessionInfo;
        if(!Test.isRunningTest()){
            sessionInfo = Auth.SessionManagement.getCurrentSession();
            
            // Set UserId
            String userId = UserInfo.getUserId();
            returnMap.put('userId', userId);

            // Set UserName
            String userName = UserInfo.getName();
            returnMap.put('userName', userName);

            // Set Last LoginDate
            String createdDate = sessionInfo.get('CreatedDate');
            list<String> dateArray = createdDate.split(' ');
            String dateString = dateArray[5]+'-'+mapMonth.get(dateArray[1])+'-'+dateArray[2]+' '+dateArray[3];
            DateTime loginTime = DateTime.valueOfGMT(dateString);
            String formattedDateStr = DateTime.newInstance(loginTime.year(), loginTime.month(), loginTime.day(), loginTime.hour(), loginTime.minute(), loginTime.second()).format(Utils.getUserDateTimeFormat());
            if((UserInfo.getLanguage()).contains('ko')){
                formattedDateStr = formattedDateStr.replace('AM', '오전');
                formattedDateStr = formattedDateStr.replace('PM', '오후');
            }
            returnMap.put('lastLoginDate', formattedDateStr);

            // Set Login IP
            String loginIp = sessionInfo.get('SourceIp');
            returnMap.put('loginIp', loginIp);
        }else{
            /*
                운영서버(Production)로 배포할때는 아래 코드가 작동하지않기 때문에 운영배포를 위한 테스트용 코드를 따로 추가
                sessionInfo = Auth.SessionManagement.getCurrentSession();
            */
            
            sessionInfo = new Map<String, String>();
            
            // Set UserId for Test
            String userId = UserInfo.getUserId();
            sessionInfo.put('userId', userId);

            // Set UserName for Test
            String userName = UserInfo.getName();
            sessionInfo.put('userName', userName);

            // Set TimeZone for Test
            String timeZone = UserInfo.getTimeZone().getID();
            sessionInfo.put('timezone', timeZone);

            // Set CreatedDate for Test
            DateTime nowDate = DateTime.now();

            Integer int_Year = nowDate.year();
            Integer int_Month = nowDate.month();
            Integer int_Day = nowDate.day();
            Integer int_Hour = nowDate.hour();
            Integer int_Minute = nowDate.minute();
            Integer int_Second = nowDate.second();

            DateTime resultDateTime = Datetime.newInstance(int_Year, int_Month, int_Day, int_Hour, int_Minute, int_Second);
            String st_resultDateTime = JSON.serialize(resultDateTime);
            sessionInfo.put('createdDate', st_resultDateTime);

            // Set LoginIP for Test
            String ip_1st = '255';
            String ip_2nd = '255';
            String ip_3rd = '255';
            String ip_4th = '255';
            String loginIp = '';
            loginIp = ip_1st;
            loginIp += '.' + ip_2nd;
            loginIp += '.' + ip_3rd;
            loginIp += '.' + ip_4th;
            sessionInfo.put('loginIp', loginIp);
            
            returnMap.put('userId', sessionInfo.get('userId'));
            returnMap.put('userName', sessionInfo.get('userName'));
            returnMap.put('lastLoginDate', sessionInfo.get('createdDate'));
            returnMap.put('loginIp', sessionInfo.get('loginIp'));
        }
        
        return returnMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<BulletinBoard__c> getBulletinBoard() {
        return [SELECT Id, Name FROM BulletinBoard__c WHERE Id='a0b3K000004CagUQAS'];
    }


}