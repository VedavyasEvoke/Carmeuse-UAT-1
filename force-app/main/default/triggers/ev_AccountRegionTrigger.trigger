trigger ev_AccountRegionTrigger on Account (before insert, before update) {
    
        ev_AccountRegionTriggerHandler.handleCountryRegions(Trigger.new, Trigger.oldMap);

}