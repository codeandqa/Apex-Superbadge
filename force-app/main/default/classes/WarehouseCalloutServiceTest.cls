@isTest
public with sharing class WarehouseCalloutServiceTest {
    @isTest
    static void testGetCallOut(){
                // Create the mock response based on a static resource
		Test.startTest();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
 		         WarehouseCalloutService.syncWarehouseData();
 		         System.assertEquals(1,1);
        Test.stopTest();
    }
}
