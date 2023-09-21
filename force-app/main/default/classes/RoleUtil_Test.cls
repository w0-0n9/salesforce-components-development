@isTest
private class RoleUtil_Test {
	
    @isTest static void test_method_one() {        
        UserRole RoleId = [SELECT ID FROM UserRole LIMIT 1][0];
        String str = RoleUtil.getTreeJSON(RoleId.Id, false);
	}
   
}