@isTest
public with sharing class MaintenanceRequestHelperTest {

    @isTest
    static void verifyCaseWithClearDueDate(){
            //create a case,
        List<Product2> lstOfEqpmnts = new List<Product2>();
        Product2 eqip = new Product2(Name = 'Test Equipment',
                                    Maintenance_Cycle__c = 10,
                                    Cost__c = 100,
                                    Current_Inventory__c = 10,
                                    Lifespan_Months__c = 10,
                                    Replacement_Part__c = true,
                                    Warehouse_SKU__c = 'abc');
        lstOfEqpmnts.add(eqip);
        
        INSERT lstOfEqpmnts;
        Id equipId = [SELECT Id FROM Product2 WHERE NAME='Test Equipment' LIMIT 1].Id;
           
            List<Case> ls_cases = new List<Case>();
            List<Id> ls_new_cases = new List<Id>();
            for(Integer i=0; i<300;i++){
                Case mrInsert = new Case(Type = 'Routine Maintenance', Status = 'New', Origin = 'Phone', Subject='Sample '+i);
                ls_cases.add(mrInsert);
            }
            INSERT ls_cases;
            List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();

            for(Case ca: ls_cases){
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c();
                    emi.Maintenance_Request__c=ca.Id;
                    emi.Equipment__c = equipId;
                    newItems.add(emi);
            }
            INSERT newItems;
            Test.startTest();
                for(Case oldCase: ls_cases){
                oldCase.Status = 'Closed';
                }
                System.debug(ls_cases.size());
                UPDATE ls_cases;
                List<Case> newCase = [SELECT ID, Status FROM CASE where Subject LIKE 'Sample%'];
                System.assertEquals(300, newCase.size());
            //create associated items.
    }
    
    @isTest
    static void verifyCaseWithUnClearDueDate(){
    List<Product2> lstOfEqpmnts = new List<Product2>();
        Product2 eqip = new Product2(Name = 'Test Equipment2',
                                    Cost__c = 10,
                                    Current_Inventory__c = 1,
                                    Lifespan_Months__c = 10,
                                    Replacement_Part__c = true,
                                    Warehouse_SKU__c = 'xyz');
        lstOfEqpmnts.add(eqip);
        
        INSERT lstOfEqpmnts;
        Id equipId = [SELECT Id FROM Product2 WHERE Name='Test Equipment2' LIMIT 1].Id;
           
            List<Case> ls_cases = new List<Case>();
            List<Id> ls_new_cases = new List<Id>();
            for(Integer i=0; i<300;i++){
                Case mrInsert = new Case(Type = 'Routine Maintenance', Status = 'New', Origin = 'Phone', Subject='Sample '+i);
                ls_cases.add(mrInsert);
            }
            INSERT ls_cases;
            List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();

           for(Case ca: ls_cases){
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c();
                    emi.Maintenance_Request__c=ca.Id;
                    emi.Equipment__c = equipId;
                    newItems.add(emi);
            }
            INSERT newItems;
            Test.startTest();
                for(Case oldCase: ls_cases){
                oldCase.Status = 'Closed';
                }
                System.debug(ls_cases.size());
                UPDATE ls_cases;
                List<Case> newCase = [SELECT ID, Status FROM CASE where Subject LIKE 'Sample%'];
                System.assertEquals(300, newCase.size());
             Test.stopTest();
            //create associated items.
    
    
    }
}
