public with sharing class MaintenanceRequestHelper {

    public static void createRoutineMaintenance(List<Case> caseList) {
        Map<String, Integer> caseVsDueDate = getDueDate(caseList);
        List<Case> newMaintRequest = new List<Case>();
        for(Case myCase : caseList){

            Case c = new Case();
            c.Type             = 'Routine Maintenance';
            c.Status           = 'New';
            c.Origin           = 'Web';
            c.Subject          = 'Routine Maintenance as per policy'+myCase.Id;
            c.Vehicle__c       = [SELECT Vehicle__c FROM Case WHERE id= :myCase.Id].get(0).Vehicle__c;
            c.Date_Reported__c = Date.today();
            c.Date_Due__c      = (caseVsDueDate.get(myCase.Id) ==null)? Date.today() : Date.today().addDays(caseVsDueDate.get(myCase.Id));
            newMaintRequest.add(c);
        }
        insert newMaintRequest;
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