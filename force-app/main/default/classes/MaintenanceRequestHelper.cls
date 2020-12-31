public with sharing class MaintenanceRequestHelper {

    public static void createRoutineMaintenance(List<Case> caseList) {

        Map<String, Integer> caseVsDueDate = dueDates(caseList);

        List<Case> newMaintRequest = new List<Case>();
        for(Case case: caseList){
        Case c = new Case(  Type   = 'Routine Maintenance',
                            Status  = 'New',
                            Origin = 'Web',
                            Subject= 'Routine Maintenance as per policy',
                            Vehicle = case.Vehicle__c,
                            Equipment__c = c.Equipment__c,
                            Date_Reported__c=Date.today(),
                            If(caseVsDueDate.get(c.Id) !=null){
                            Date_Due__c = Date.today().addDays(caseVsDueDate.get(c.Id));
                            }else{
                            Date_Due__c = Date.today().addDays(caseVsDueDate.get(c.Id));
                            }
        );
        newMaintRequest.add(c);
        }
        insert newMaintRequest;
    }
    private static Map<String, Integer> getDueDate(List<Case> caseList){
        // Case firstCase = caseList.get(0);//5004x0000031Fq8AAE
        // firstCase = '5004x0000031Fq8AAE';
        //SELECT ID,Name,Equipment__c, Maintenance_Request__c FROM Equipment_Maintenance_Item__c
        //SELECT ID, NAME, (SELECT Id FROM Equipment_Maintenance_Items__r)FROM  Product2
        //SELECT CaseNumber,Subject, (SELECT ID, Name, equipment__C from Equipment_Maintenance_Items__r) FROM Case
        //Map to returnfor all cases. 
        Map<String, Integer> dueDates = new Map<String, Integer>();
        //Assume I am passing all cases. 
        //List<Case> caseList = [SELECT Id, CaseNumber,Subject FROM Case];
        //Convert cases into map of Id and case.
        Map<Id, Case> mapcase = new Map<Id, Case>(caseList);
        Map<String, Integer> mapOfCaseAndDueDate = new Map<String,Integer>();
        for(Case c:[SELECT ID, (SELECT ID, NAME, equipment__C  FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :mapcase.keySet()]){
                for(Equipment_Maintenance_Item__c e: c.Equipment_Maintenance_Items__r){
                    AggregateResult[] average = [SELECT MIN(Maintenance_Cycle__c) FROM Product2 WHERE Replacement_Part__c=true];
                    dueDates.put((String)c.Id, Integer.valueOf(average[0].get('expr0')));
                }
            }
            return dueDates;
    }
}