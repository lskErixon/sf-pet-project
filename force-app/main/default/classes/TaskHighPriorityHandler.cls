// file: classes/TaskHighPriorityHandler.cls
public with sharing class TaskHighPriorityHandler extends TriggerHandler {

  public override void afterInsert() {
    handle(Trigger.new, null);
  }

  public override void afterUpdate() {
    handle(Trigger.new, Trigger.oldMap);
  }

  public void handle(List<SObject> newRecords, Map<Id, SObject> oldMap) {
    List<Task__c> castNew = new List<Task__c>();
    for (SObject s : newRecords) {
      castNew.add((Task__c)s);
    }

    Map<Id, Task__c> castOld = null;
    if (oldMap != null) {
      castOld = new Map<Id, Task__c>();
      for (Id i : oldMap.keySet()) {
        castOld.put(i, (Task__c)oldMap.get(i));
      } 
    }
      handleInternal(castNew, castOld);
    }

  private static void handleInternal(List<Task__c> newRecords, Map<Id, Task__c> oldMap) {
    Set<Id> toAlert = new Set<Id>();

    for (Task__c rec : newRecords) {
      if (rec.High_Priority__c != true || rec.Person__c == null) {
        continue;
      } 

      if (oldMap == null) {
                toAlert.add(rec.Id);
            } else {
        Task__c oldRec = oldMap.get(rec.Id);
        Boolean flagChanged   = rec.High_Priority__c != oldRec.High_Priority__c;
        Boolean personChanged = rec.Person__c != oldRec.Person__c;
        if (flagChanged || personChanged) {
          toAlert.add(rec.Id);
        }
      }
    }

    if (!toAlert.isEmpty()) {
      HighPriorityTaskAlertService.sendAlertsAsync(new List<Id>(toAlert));
    }
  }
}
