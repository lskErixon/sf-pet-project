public with sharing class TaskPersonGuardHandler extends TriggerHandler {

  private static final String STATUS_COMPLETED = 'Completed';

  public override void beforeUpdate() {
    List<Task__c> newTaskRecordList = (List<Task__c>) Trigger.new;
    List<Task__c> oldTaskRecordList = (List<Task__c>) Trigger.old;
    for (Integer i = 0; i < newTaskRecordList.size(); i++) {
      Task__c newTaskRecord = newTaskRecordList[i];
      Task__c oldTaskRecord = oldTaskRecordList[i];

      Boolean isPersonChanged    = newTaskRecord.Person__c != oldTaskRecord.Person__c;
      Boolean isCompletedNow     = newTaskRecord.Status__c == STATUS_COMPLETED;
      Boolean wasCompletedBefore = oldTaskRecord.Status__c == STATUS_COMPLETED;

      if (isPersonChanged && (isCompletedNow || wasCompletedBefore)) {
        newTaskRecord.Person__c.addError(
          'Cannot change Person__c on a task with Status = Completed.'
        );
      }
    }
  }
}
