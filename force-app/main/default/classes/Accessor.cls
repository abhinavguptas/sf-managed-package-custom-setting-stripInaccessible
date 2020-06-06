/**
 * Utility class to quickly check the CRUD/FLS behavior on public and protected custom settings via 
 * Classic DescribeSObjectResult/DescribeFieldResult Apex methods like isAccessible(), isCreateable() etc
 * or a shorthand approach of Security.stripInaccessible(...)
 * 
 * This class will test the use case of protected custom settings issue with Security.stripInaccessible(...), which
 * always reports a false 
 */
global inherited sharing class Accessor {


    global class AccessorException extends Exception{}
    
    /**
     * Single method to setup sample data in all custom settings 
     */
    global static void populateAll() {
        populateProtectedHierarchy();
        populateProtectedList();
        populatePublicHierarchy();
        populatePublicList();
    }

    /**
     * Check given accessType on a PUBLIC + LIST Custom Setting, using Security.stripInaccessible(accessType, ..);
     * @throws System.NoAccessException or AccessorException: automatically via Security.stripInaccessible(..) 
     * or manually after reviewing if any fields got removed fields via 
     * Map<String,Set<String>> removedFields = decision.getRemovedFields();
     */
    global static void accessPublicList(AccessType accessType){
        Public_List__c[] all = Public_List__c.getAll().values();
        assertAccess(accessType, all);
    }
    
    /**
     * Check given accessType on a PROTECTED + LIST Custom Setting, using Security.stripInaccessible(accessType, ..);
     * @throws System.NoAccessException or AccessorException: automatically via Security.stripInaccessible(..) 
     * or manually after reviewing if any fields got removed fields via 
     * Map<String,Set<String>> removedFields = decision.getRemovedFields();
     */
    global static void accessProtectedList(AccessType accessType){
        Protected_List__c[] all = Protected_List__c.getAll().values();
        assertAccess(accessType, all);
    }

    /**
     * Check given accessType on a PUBLIC + HIERARCHY Custom Setting, using Security.stripInaccessible(accessType, ..);
     * @throws System.NoAccessException or AccessorException: automatically via Security.stripInaccessible(..) 
     * or manually after reviewing if any fields got removed fields via 
     * Map<String,Set<String>> removedFields = decision.getRemovedFields();
     */
    global static void accessPublicHierarchy(AccessType accessType){
        Public_Hierarchy__c record = Public_Hierarchy__c.getInstance();
        assertAccess(accessType, new SObject[]{record});
    }
    
    /**
     * Check given accessType on a PROTECTED + HIERARCHY Custom Setting, using Security.stripInaccessible(accessType, ..);
     * @throws System.NoAccessException or AccessorException: automatically via Security.stripInaccessible(..) 
     * or manually after reviewing if any fields got removed fields via 
     * Map<String,Set<String>> removedFields = decision.getRemovedFields();
     */
    global static void accessProtectedHierarchy(AccessType accessType){
        Protected_Hierarchy__c record = Protected_Hierarchy__c.getInstance();
        assertAccess(accessType, new SObject[]{record});
    }
    
    /**
     * Generates a simple text based Object/Field CRUD/FLS report for all 4 Custom settings, i.e. 
     * 1. Protected_Hierarchy__c
     * 2. Protected_List__c
     * 3. Public_Hierarchy__c
     * 4. Public_List__c
     * This report covers objects CRUD permissions, and FLS details on all the 
     * standard and custom fields
     */
    global static String generateClassicAccessReport() {
        String result = '';

        result += accessReportFor(Protected_Hierarchy__c.sObjectType.getDescribe());
        result += accessReportFor(Public_Hierarchy__c.sObjectType.getDescribe());
        result += accessReportFor(Protected_List__c.sObjectType.getDescribe());
        result += accessReportFor(Public_List__c.sObjectType.getDescribe());        

        return result;       
    }

    /**
     * Creates a dummy record of Protected_Hierarchy__c custom setting.
     */
    global static void populateProtectedHierarchy(){
        // create with custom settings with current time
        Protected_Hierarchy__c ph = new Protected_Hierarchy__c(Value__c = String.valueOf(Datetime.now()));
        insert ph;
    }
    
    /**
     * Creates a dummy record of Public_Hierarchy__c custom setting.
     */
    global static void populatePublicHierarchy(){
        // create with custom settings with current time
        Public_Hierarchy__c ph = new Public_Hierarchy__c(Value__c = String.valueOf(Datetime.now()));
        insert ph;
    }
    
    /**
     * Creates a dummy record of Protected_Hierarchy__c custom setting.
     */
    global static void populateProtectedList(){
        // create with custom settings with current time
        String randomText = String.valueOf(Datetime.now());
        Protected_List__c pl = new Protected_List__c(Name = randomText, Value__c = randomText);
        insert pl;
    }
         
    /**
     * Creates a dummy record of Public_List__c custom setting.
     */
    global static void populatePublicList(){
        // create with custom settings with current time
        String randomText = String.valueOf(Datetime.now());
        Public_List__c pl = new Public_List__c(Name = randomText, Value__c = randomText);
        insert pl;
    }
    
    /**
     * A utility methods which generates a complete object and field access report for a given object's DescribeSObjectResult
     */
    static String accessReportFor(Schema.DescribeSObjectResult dsr) {
        String result = '\n\n Access Report for Object: ' + dsr.getName() ;
        // CRUD/FLS log information row per field or Object
        String rowTemplate = '\n {0} : {1} is Accessible: {2},  Createable: {3}, Updateable: {4}';

        result += String.format(rowTemplate,
                                 new String[]{
                                        'Object',
                                        dsr.getName().rightPad(19),
                                        String.valueOf(dsr.isAccessible()),
                                        String.valueOf(dsr.isCreateable()),
                                        String.valueOf(dsr.isUpdateable())                                            
                                 });

        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        
        
        for (Schema.SObjectField sof: fieldMap.values()) {
            Schema.DescribeFieldResult dfr = sof.getDescribe(); 
            result += String.format(rowTemplate,
                                    new String[]{
                                            'Field',
                                            dfr.getLabel().rightPad(20),
                                            String.valueOf(dfr.isAccessible()),
                                            String.valueOf(dfr.isCreateable()),
                                            String.valueOf(dfr.isUpdateable())                                            
                                            });
        }        
        return result + '\n\n';
    }
    
    /**
     * The core method which uses Security.stripInaccessible(...) to assert a given AccessType on bunch of records.
     * 
     * @param accessType The access to be asserted on the given records
     * @param records Records against which the accessType will be asserted.
     *
     * @throws System.NoAccessException or AccessorException: automatically via Security.stripInaccessible(..) 
     * or manually after reviewing if any fields got removed fields via 
     * Map<String,Set<String>> removedFields = decision.getRemovedFields();
     */
    static void assertAccess(AccessType accessType, SObject[] records){
        if (records == null || accessType == null || records.isEmpty()) {
            return;
        }
        String objectName = records[0].getSObjectType().getDescribe().getLabel();
         
         // Strip fields that are not updatable
         SObjectAccessDecision decision = Security.stripInaccessible(accessType, records); // Protected Custom Settings fail on this line
         //K: SObject Name, V: Set of Field Names which are not accessible. 
         Map<String,Set<String>> removedFields = decision.getRemovedFields();
         
         
         for(String objName : removedFields.keySet()){
             //Name of missing access fields as CSV;
             String fieldsCSV = String.join(new List<String>(removedFields.get(objName)), ',');
             String msg =  String.format('"{0}" access missing on Fields:"{1}" from Object: "{2}"', 
                                         new String[]{
                                             accessType.name(), fieldsCSV, objectName
                                                 });
             throw new AccessorException(msg);
         }            
         
    }
    
}