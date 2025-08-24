public with sharing class ProjectStatusFromTasksHandler extends TriggerHandler {

  public override void afterInsert() {
    runRecalc((List<Task__c>) Trigger.new, null);
  }

  public override void afterUpdate() {
    runRecalc((List<Task__c>) Trigger.new, (List<Task__c>) Trigger.old);
  }

  private void runRecalc(List<Task__c> newTaskList, List<Task__c> oldTaskList) {
    Set<Id> projectIdSet = ProjectStatusFromTasksService.collectProjectIdsFromTaskRecords(newTaskList, oldTaskList);
    if (projectIdSet.isEmpty()) return;
    ProjectStatusFromTasksService.recalculateForProjects(projectIdSet);
  }
}
