public class RoleUtil {

    /**
     * Properties used by getRootNodeOfUserTree function - starts
     */
    // Map to hold roles with Id as the key
    private static  Map<Id, UserRole>               roleUsersMap;

    // Map to hold child roles with parentRoleId as the key
    private static  Map<Id, List<UserRole>>         parentChildRoleMap;

    // List holds all subordinates
    private static  List<User>                      allSubordinates         { get; set; }
        
    // Global JSON generator
    private static  JSONGenerator                   gen                     { get; set; }
    /**
     * Properties used by getRootNodeOfUserTree function - ends
     */
    
    
    /**
     * Properties used by getSObjectTypeById function - starts
     */
    // map to hold global describe data
    private static  Map<String,Schema.SObjectType>  gd;
    
    // map to store objects and their prefixes
    private static  Map<String, String>             keyPrefixMap;

    // to hold set of all sObject prefixes
    private static  Set<String>                     keyPrefixSet;
    /**
     * Properties used by getSObjectTypeById function - ends
     */
    
    /**
     * initialize helper data
     */ 
    static {
        // initialize helper data for getSObjectTypeById function
        init1();
        
        // initialize helper data for getRootNodeOfUserTree function
        init2();
    }
    
    /**
     * init1 starts <to initialise helper data>
     */
    private static void init1() {
        // get all objects from the org
        gd = Schema.getGlobalDescribe();
        
        // to store objects and their prefixes
        keyPrefixMap = new Map<String, String>{};
        
        //get the object prefix in IDs
        keyPrefixSet = gd.keySet();
        
        // fill up the prefixes map
        for(String sObj : keyPrefixSet) {
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            keyPrefixMap.put(tempPrefix, tempName);
        }
    }

    /**
     * init2 starts <to initialise helper data>
     */
    private static void init2() {
        
        // Create a blank list
        allSubordinates = new List<User>();
        
        // Get role to users mapping in a map with key as role id
        roleUsersMap = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId, (SELECT Id, Name FROM Users) FROM UserRole ORDER BY ParentRoleId]);
        
        // populate parent role - child roles map
        parentChildRoleMap = new Map <Id, List<UserRole>>();        
        for (UserRole r : roleUsersMap.values()) {
            List<UserRole> tempList;
            if (!parentChildRoleMap.containsKey(r.parentRoleId)){
                tempList = new List<UserRole>();
                tempList.Add(r);
                parentChildRoleMap.put(r.parentRoleId, tempList);
            }
            else {
                tempList = (List<UserRole>)parentChildRoleMap.get(r.parentRoleId);
                tempList.add(r);
                parentChildRoleMap.put(r.parentRoleId, tempList);
            }
        }
    } 

    /**
     * public method to get the starting node of the RoleTree along with user list
     */
    public static RoleNodeWrapper getRootNodeOfUserTree (Id userOrRoleId, Boolean incUser) {
        return createNode(userOrRoleId, incUser);
    }
    
    /**
     * createNode starts
     */
    private static RoleNodeWrapper createNode(Id objId, Boolean incUser) {
        RoleNodeWrapper n = new RoleNodeWrapper();
        Id roleId;
        if (isRole(objId)) {
            roleId = objId;
            if (incUser && !roleUsersMap.get(roleId).Users.isEmpty()) {
                n.myUsers = roleUsersMap.get(roleId).Users;
                allSubordinates.addAll(n.myUsers);
                n.hasUsers = true;
            }
        } else {
            List<User> tempUsrList = new List<User>();
            User tempUser = [SELECT Id, Name, UserRoleId FROM User WHERE Id =: objId];
            if(incUser){
                tempUsrList.add(tempUser);
                n.myUsers = tempUsrList;
            }
            roleId = tempUser.UserRoleId;
        }
        n.myRoleId = roleId;
        n.myRoleName = roleUsersMap.get(roleId).Name;
        n.myParentRoleId = roleUsersMap.get(roleId).ParentRoleId;

        if (parentChildRoleMap.containsKey(roleId)){
            n.hasChildren = true;
            n.isLeafNode = false;
            List<RoleNodeWrapper> lst = new List<RoleNodeWrapper>();
            for (UserRole r : parentChildRoleMap.get(roleId)) {
                lst.add(createNode(r.Id, incUser));
            }          
            n.myChildNodes = lst;
        }
        else {
            n.isLeafNode = true;
            n.hasChildren = false;
        }
        return n;
    }
    
    public static List<User> getAllSubordinates(Id userId){
        createNode(userId, true);
        return allSubordinates;
    }
    
    public static String getTreeJSON(Id userOrRoleId, Boolean includeUser) {
        gen = JSON.createGenerator(true);
        RoleNodeWrapper node = createNode(userOrRoleId, includeUser);
        gen.writeStartArray();
        convertNodeToJSON(node);
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    private static void convertNodeToJSON(RoleNodeWrapper objRNW){
        gen.writeStartObject();
        gen.writeStringField('label', objRNW.myRoleName);
        gen.writeStringField('name', objRNW.myRoleId);
        gen.writeBooleanField('disabled', false);
        gen.writeBooleanField('expanded', false);
        //gen.writeBooleanField('isFolder', true);
        if (objRNW.hasUsers || objRNW.hasChildren){
            gen.writeFieldName('items');
            gen.writeStartArray();
            if (objRNW.hasUsers){
                for (User u : objRNW.myUsers){
                    gen.writeStartObject();
                    gen.writeStringField('label', u.Name);
                    gen.writeStringField('name', u.Id);
                    gen.WriteEndObject();
                }
            }
            if (objRNW.hasChildren){
                for (RoleNodeWrapper r : objRNW.myChildNodes){
                    convertNodeToJSON(r);
                }
            }
            gen.writeEndArray();
        }
        gen.writeEndObject();
    }
    
    /**
     * general utility function to get the SObjectType of the Id 
     * passed as the argument, to be used in conjunction with
     */ 
    public static String getSObjectTypeById(Id objectId) {
        String tPrefix = objectId;
        tPrefix = tPrefix.subString(0,3);
        
        //get the object type now
        String objectType = keyPrefixMap.get(tPrefix);
        return objectType;
    }
    
    /**
     * check the object type of objId using the utility function 
     * getSObjectTypeById and return 'true' if it's of Role type
     */
    public static Boolean isRole (Id objId) {
        if (getSObjectTypeById(objId) == String.valueOf(UserRole.sObjectType)) {
            return true;
        } else if (getSObjectTypeById(objId) == String.valueOf(User.sObjectType)) {
            return false;
        } 
        return false;
    }
    
    public class RoleNodeWrapper {
    
        // Role info properties - begin
        public  String                  myRoleName      { get; set; }
        public  Id                      myRoleId        { get; set; }
        public  String                  myParentRoleId  { get; set; }
        // Role info properties - end
        
        // Node children identifier properties - begin
        public  Boolean                 hasChildren     { get; set; }
        public  Boolean                 isLeafNode      { get; set; }
        public  Boolean                 hasUsers        { get; set; }
        // Node children identifier properties - end
        
        // Node children properties - begin
        public  List<User>              myUsers         { get; set; }
        public  List<RoleNodeWrapper>   myChildNodes    { get; set; }
        // Node children properties - end   
        
        public RoleNodeWrapper(){
            hasUsers = false;
            hasChildren = false;
        }
    }   
         
 }