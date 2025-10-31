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

    for (Task__c record : newRecords) {
      if (record.High_Priority__c != true || record.Person__c == null) {
        continue;
      }

    if (oldMap == null) {
        toAlert.add(record.Id);
    } else {
        Task__c oldRecord = oldMap.get(record.Id);
      if (shouldSendAlert(record, oldRecord)) {
        toAlert.add(record.Id);
      }
    }
  }

  if (!toAlert.isEmpty()) {
      HighPriorityTaskAlertService.sendAlertsAsync(new List<Id>(toAlert));
    }
  }

  private static Boolean shouldSendAlert(Task__c newRecord, Task__c oldRecord) {
    if (oldRecord == null) {
        return true;
    }
    Boolean highPriorityChanged = newRecord.High_Priority__c != oldRecord.High_Priority__c;
    Boolean personChanged = newRecord.Person__c != oldRecord.Person__c;
    return highPriorityChanged || personChanged;
  }
}
