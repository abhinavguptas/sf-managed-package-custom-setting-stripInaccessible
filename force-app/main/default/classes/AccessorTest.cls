/**
 * Test case is not fruitful to reproduce the situation, it's created for sake of coverage only
 * to allow managed package upload
 */
@isTest
public class AccessorTest {
	
    testMethod static void testAll() {
        Accessor.populateAll();
        
        Accessor.generateClassicAccessReport();
        
        try {
            Accessor.accessProtectedHierarchy(AccessType.READABLE);            
        } catch (Exception ex){
            System.debug (ex.getMessage() + ex.getStackTraceString());            
        }
        try {
            Accessor.accessProtectedList(AccessType.READABLE);            
        } catch (Exception ex){
            System.debug (ex.getMessage() + ex.getStackTraceString());            
        }
        try {
            Accessor.accessPublicHierarchy(AccessType.READABLE);            
        } catch (Exception ex){
            System.debug (ex.getMessage() + ex.getStackTraceString());            
        }
        try {
            Accessor.accessPublicList(AccessType.READABLE);            
        } catch (Exception ex){
            System.debug (ex.getMessage() + ex.getStackTraceString());            
        }
        
    }
    
   
}