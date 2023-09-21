public with sharing class RecordLockController {
    
    @AuraEnabled
    public static String initComponent(String recordId){
        system.debug(LoggingLevel.ERROR, '*** RecordLockController initComponent Start !!! ');
        
        try {
           
            Map<String, Object> responseMap = new Map<String, Object>();

            List<PermissionSetAssignment> modifyAllUserList =  [SELECT AssigneeId FROM PermissionSetAssignment 
                                                                WHERE PermissionSet.PermissionsModifyAllData = true AND AssigneeId = :UserInfo.getUserId()];

            responseMap.put('isLocked', Approval.isLocked(recordId));
            responseMap.put('canModifyAll', !modifyAllUserList.isEmpty());

            system.debug(LoggingLevel.ERROR, '*** RecordLockController initComponent End !!! ');

            return JSON.serialize(responseMap);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void lockRecord(String recordId){
        system.debug(LoggingLevel.ERROR, '*** RecordLockController lockRecord : ' + recordId);
        Approval.lock(recordId);
    }

    @AuraEnabled
    public static void unlockRecord(String recordId){
        system.debug(LoggingLevel.ERROR, '*** RecordLockController unlockRecord : ' + recordId);
        Approval.unlock(recordId);
    }
    
}