public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> caseList) {
        // TODO: Complete the method to update workorders
        List<case> newCases = new List<Case>();
        Map<String,Integer> result=getDueDate(caseList);
        List<Id> clonedCaseIds = new List<Id>();
        List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();
		
        for(Case c : caseList){
            if(c.status=='Closed')
                if(c.type=='Repair' || c.type=='Routine Maintenance'){
                    Case newCase = new Case();
                    newCase.Status='New';
                    newCase.Origin='web';
                    newCase.Type='Routine Maintenance';
                    newCase.Subject='Routine Maintenance of Vehicle';
                    newCase.Vehicle__c=c.Vehicle__c;
                    newCase.Master_Id__c = c.Id;
                    newCase.Date_Reported__c=Date.today();
                    if(result.get(c.Id)!=null)
                        newCase.Date_Due__c=Date.today()+result.get(c.Id);
                    else
                        newCase.Date_Due__c=Date.today();
                    newCases.add(newCase);
                    clonedCaseIds.add(c.Id);
                }
        }        
        insert newCases;   
        
        List<Equipment_Maintenance_Item__c> items=
            [select id,name,Maintenance_Request__c from Equipment_Maintenance_Item__c where Maintenance_Request__c in:clonedCaseIds];
        
        for(Case caseO : newCases){
            
            for(Equipment_Maintenance_Item__c item : items){
                if(caseO.Master_Id__c==item.Maintenance_Request__c){
                    Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
                    newItem.Maintenance_Request__c=caseO.Id;
                    newItems.add(newItem);
                }
            }
        }
        insert newItems;
    }        
    
    public static Map<String,Integer> getDueDate(List<Case> CaseIDs){
        Map<String,Integer> result = new Map<String,Integer>();
        Map<Id, case> caseKeys = new Map<Id, case> (CaseIDs);        
        List<AggregateResult> wpc=[select Maintenance_Request__r.ID cID,min(Equipment__r.Maintenance_Cycle__c)cycle
                                   from Equipment_Maintenance_Item__c where  Maintenance_Request__r.ID in :caseKeys.keySet() group by  Maintenance_Request__r.ID ];
        for(AggregateResult res :wpc){
            Integer addDays=0;
            if(res.get('cycle')!=null)
                addDays+=Integer.valueOf(res.get('cycle'));
            result.put((String)res.get('cID'),addDays);
        }
        return result;
    }
}
