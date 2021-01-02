List<Case> somecases = [SELECT id FROM Case WHERE status='New'];
MaintenanceRequestHelper.createRoutineMaintenance(somecases);
/Users/aditya.kumar/Documents/dev/Salesforce/Superbadge/force-app/main/default/classes/MaintenanceRequestHelper.cls  Illegal assignment from Integer to Date (24:13)

List<Case> caseList = new List<Case>();
    if(Trigger.isUpdate && Trigger.IsAfter){
        for(Case ca: Trigger.New){
            if(ca.IsClosed && (ca.Type.equals('Repair') || ca.Type.equals('Routine Maintenance')))
            {
                caseList.add(ca);
            }
        }
        if(caseList.size()>0){
            MaintenanceRequestHelper.updateWorkOrders(caseList);
        }
        
    }