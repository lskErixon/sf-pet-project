public with sharing class TaskPersonGuardHandler extends TriggerHandler {
  private static final String STATUS_COMPLETED = 'Completed';

  public override void beforeUpdate() {
    Map<Id, Task__c> oldMap = (Map<Id, Task__c>) Trigger.oldMap;

    for (Task__c taskNew : (List<Task__c>) Trigger.new) {
      Task__c taskOld = oldMap.get(taskNew.Id);

      if ((taskNew.Status__c == STATUS_COMPLETED || taskOld.Status__c == STATUS_COMPLETED)
        && taskNew.Person__c != taskOld.Person__c) {
          taskNew.Person__c.addError('Cannot change Person__c on a task once it is marked as Completed.');
      }
    }
  }
}
