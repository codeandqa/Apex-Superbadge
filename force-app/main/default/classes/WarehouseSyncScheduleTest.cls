@isTest
public with sharing class WarehouseSyncScheduleTest {
    @isTest
    static void testSyncSchedule(){
        String sch = '0 0 0 * * ? 2021';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String jobId = System.schedule('WarehouseSyncScheduleTest', sch, new WarehouseSyncSchedule());
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            
            System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
}
