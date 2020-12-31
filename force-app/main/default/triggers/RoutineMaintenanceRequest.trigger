trigger RoutineMaintenanceRequest on Case (before update, after update) {
    List<Case> caseList = new List<Case>();
    if(Trigger.isUpdate && Trigger.IsAfter){
        for(Case ca: Trigger.New){
            if(ca.IsClosed && (ca.Type.equals('Repair') || ca.Type.equals('Routine Maintenance')))
            {
                caseList.add(ca);
            }
        }
        if(caseList.size()>0){
            
            MaintenanceRequestHelper.createRoutineMaintenance(caseList);
        }
        
    }
}