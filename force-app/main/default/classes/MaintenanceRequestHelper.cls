public with sharing class MaintenanceRequestHelper {

    public static void createRoutineMaintenance(List<Case> caseList) {
        //TODO: NEED TO FIX: System.LimitException: Too many SOQL queries: 101
        Map<String, Integer> caseVsDueDate = getDueDate(caseList);
        List<sObject> newMaintRequest = new List<sObject>();
        //==============Handling Equipment Info===================//
        Map<Id, List<Equipment_Maintenance_Item__c>> emtCaseIDmap = new Map<Id, List<Equipment_Maintenance_Item__c>>();

        for(Case c:[SELECT ID, (SELECT ID, NAME, equipment__C,Quantity__c  FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :caseVsDueDate.keySet()])
        {
            List<Equipment_Maintenance_Item__c> emtIds = new List<Equipment_Maintenance_Item__c>();
            for(Equipment_Maintenance_Item__c e: c.Equipment_Maintenance_Items__r)
            {
                emtIds.add(e);
            }
            emtCaseIDmap.put(c.Id, emtIds);
        }
        //===========
        for(Case myCase : caseList){
            Case c = new Case();
            c.Type             = 'Routine Maintenance';
            c.Status           = 'New';
            c.Origin           = 'Web';
            c.Subject          = 'Routine Maintenance as per policy';
            c.Master_Id__c     = 'NewItems';
            c.Vehicle__c       = [SELECT Vehicle__c FROM Case WHERE id= :myCase.Id].get(0).Vehicle__c;
            c.Date_Reported__c = Date.today();
            c.Date_Due__c      = (caseVsDueDate.get(myCase.Id) ==null)? Date.today() : Date.today().addDays(caseVsDueDate.get(myCase.Id));
            insert c;
            List<Equipment_Maintenance_Item__c> lstEMI = [SELECT equipment__C, Quantity__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c=:myCase.Id];
            for(Equipment_Maintenance_Item__c e: lstEmI){
                Equipment_Maintenance_Item__c cont= new Equipment_Maintenance_Item__c(equipment__C=e.equipment__C,Quantity__c=e.Quantity__c,Maintenance_Request__c=c.Id);
                newMaintRequest.add(cont);
            }
            insert newMaintRequest;
        }
        //insert newMaintRequest;
    }
    public static Map<String, Integer> getDueDate(List<Case> caseList){
        Map<String, Integer> dueDates = new Map<String, Integer>();
        Map<Id, Case> mapcase = new Map<Id, Case>(caseList);
        Map<String, Integer> mapOfCaseAndDueDate = new Map<String,Integer>();
        for(Case c:[SELECT ID, (SELECT ID, NAME, equipment__C  FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :mapcase.keySet()]){
                //for(Equipment_Maintenance_Item__c e: c.Equipment_Maintenance_Items__r){
                    AggregateResult[] average = [SELECT MIN(Maintenance_Cycle__c) FROM Product2 WHERE Replacement_Part__c=true];
                    dueDates.put((String)c.Id, Integer.valueOf(average[0].get('expr0')));
                //}
            }
        return dueDates;
    }
}