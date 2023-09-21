@isTest
private class LoginUserInfoController_Test {
    @isTest static void test_method_1() {
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            LoginUserInfoController.getLoginUserInfo();    
        }
        Test.stopTest();
    }
}