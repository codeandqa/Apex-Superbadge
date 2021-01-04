public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        List<Product2> prodList             = new List<Product2>();
        List<Map<String,Object>> listOfMaps = new List<Map<String,Object>>();

        Http http               = new Http();
        HttpRequest request     = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        HttpResponse response   = http.send(request);
        if (response.getStatusCode() == 200) {
            List<Object> equipments = (List<Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Received the following equipments:');
            for (Object equipment: equipments) {
                Map<String,Object> mp_StrObj    = (Map<string,Object>)equipment;
                Product2 product                = new Product2();
                product.Name                    = String.valueOf(mp_StrObj.get('name'));
                product.Replacement_Part__c     = true;
                product.Cost__c                 = Integer.ValueOf(mp_StrObj.get('cost'));
                product.Current_Inventory__c    = Integer.ValueOf(mp_StrObj.get('quantity'));
                product.Lifespan_Months__c      =  Integer.ValueOf(mp_StrObj.get('lifespan'));
                product.Maintenance_Cycle__c    = Integer.ValueOf(mp_StrObj.get('maintenanceperiod'));
                product.Warehouse_SKU__c        = String.valueOf(mp_StrObj.get('sku'));
                prodList.add(product);
                
            }
            upsert prodList;
        }
    }
}