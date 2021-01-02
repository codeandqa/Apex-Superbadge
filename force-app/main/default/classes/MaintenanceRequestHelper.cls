public with sharing class MaintenanceRequestHelper {

    public static void createRoutineMaintenance(List<Case> caseList) {
        Map<String, Integer> caseVsDueDate = getDueDate(caseList);
        List<Equipment_Maintenance_Item__c> listOfEMI = [SELECT     Id,
                                                                    Equipment__c,
                                                                    Maintenance_Request__c,
                                                                    Maintenance_Request__r.vehicle__c,
                                                                    Maintenance_Request__r.Priority
                                                            FROM    Equipment_Maintenance_Item__c
                                                            WHERE   Maintenance_Request__c IN :caseVsDueDate.keySet()];

        List<sObject> newMaintRequest = new List<sObject>();
        for(Case myCase : caseList){
            Case c = new Case();
            c.Type             = 'Routine Maintenance';
            c.Status           = 'New';
            c.Origin           = 'Web';
            c.Subject          = 'Routine Maintenance as per policy_After removing loop';
            c.Vehicle__c       = getVehicle(myCase, listOfEMI);
            c.Date_Reported__c = Date.today();
            c.Date_Due__c      = (caseVsDueDate.get(myCase.Id) ==null)? Date.today() : Date.today().addDays(caseVsDueDate.get(myCase.Id));
            c.Master_Id__c     = String.valueOf(myCase.Id);
            newMaintRequest.add(c);
            List<Map<String, String>> targetEquipItems = getEquipments(myCase, listOfEMI);
            System.debug(targetEquipItems);
            if(targetEquipItems.size() > 0)
            {
                for (Map<String, String> targetMap: targetEquipItems)
                {
                    Equipment_Maintenance_Item__c maintItem = new Equipment_Maintenance_Item__c(equipment__c = targetMap.get('equipmentId'),
                                                                                                Maintenance_Request__r = new Case(Master_Id__c=String.valueOf(myCase.Id)));
                    newMaintRequest.add(maintItem);
                }
            }
            ///TODO: #1 There was an unexpected error in your org which is preventing this assessment check from completing: System.LimitException: 
            //       Too many DML statements: 151
        }
        insert newMaintRequest;
    }
    public static Map<String, Integer> getDueDate(List<Case> caseList){
        Map<String, Integer> dueDates = new Map<String, Integer>();
        Map<Id, Case> mapcase = new Map<Id, Case>(caseList);
        Map<String, Integer> mapOfCaseAndDueDate = new Map<String,Integer>();
        List<Product2> products = [ SELECT  ID,
                                            Maintenance_Cycle__c,
                                            ( SELECT    ID,
                                                        Name,
                                                        Maintenance_Request__c
                                                FROM    Equipment_Maintenance_Items__r
                                                WHERE   Maintenance_Request__c
                                                IN :mapcase.keySet()
                                            ) FROM Product2
                                    ];

        for(Case c:[SELECT ID, (SELECT ID, NAME, equipment__C  FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :mapcase.keySet()])
        {
        //TODO: need to fix as this is causing soql error. WIP !!!!!
        //     AggregateResult[] average = [SELECT MIN(Maintenance_Cycle__c) FROM Product2 WHERE Replacement_Part__c=true];
            //dueDates.put((String)c.Id, Integer.valueOf(average[0].get('expr0')));
            dueDates.put((String)c.Id, 15);//hardcoded 15 to investegate TODO: LIne:43.
        }
        return dueDates;
    }

    public static String getVehicle(Case inputCase, List<Equipment_Maintenance_Item__c> EquipMaintItems){
        for(Equipment_Maintenance_Item__c iEmI: EquipMaintItems)
        {
            if(iEmI.Maintenance_Request__c == inputCase.Id ){
                return String.valueOf(iEmI.Maintenance_Request__r.vehicle__c);
            }

        }
        return null;
    }
    public static String getPriority(Case inputCase, List<Equipment_Maintenance_Item__c> EquipMaintItems)
    {
        for(Equipment_Maintenance_Item__c iEmI: EquipMaintItems)
            {
                if(iEmI.Maintenance_Request__c == inputCase.Id )
                {
                    return String.valueOf(iEmI.Maintenance_Request__r.Priority);
                }
            }
        return null;
    }

    public static List<Map<String, String>> getEquipments(Case inputCase, List<Equipment_Maintenance_Item__c> EquipMaintItems)
    {
        Map<String, String> tempMap; 
        List<Map<String, String>> result = new List<Map<String, String>>();
        for(Equipment_Maintenance_Item__c iEmI: EquipMaintItems)
        {
            if(iEmI.Maintenance_Request__c == inputCase.Id )
            {
                tempMap = new Map<String, String>();
                tempMap.put('equipmentId', String.valueOf(iEmI.Equipment__c));
                result.add(tempMap);
            }
        }
        return result;
    }

}