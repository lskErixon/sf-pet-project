public with sharing class ProjectStatusFromTasksHandler extends TriggerHandler {

    public override void afterInsert() {
        recalculateStatuses((List<Task__c>) Trigger.new, null);
    }

    public override void afterUpdate() {
        recalculateStatuses((List<Task__c>) Trigger.new, (List<Task__c>) Trigger.old);
    }

  private void recalculateStatuses(List<Task__c> newTaskList, List<Task__c> oldTaskList) {
    Set<Id> projectIdSet = new Set<Id>();
    if (newTaskList != null) {
      for (Task__c t : newTaskList) {
          projectIdSet.add(t.Project__c);
      }
    }
    if (oldTaskList != null) {
      for (Task__c t : oldTaskList) {
          projectIdSet.add(t.Project__c);
      }
    }
    projectIdSet.remove(null);
    if (projectIdSet.isEmpty()) {
      return;
    }

    Map<Id, Project__c> projectsById = new Map<Id, Project__c>([
      SELECT Id, Status__c, Planed_End_Date__c
      FROM Project__c
      WHERE Id IN :projectIdSet
    ]);
    if (projectsById.isEmpty()) {
      return;
    }

    Map<Id, List<Task__c>> tasksByProjectId = new Map<Id, List<Task__c>>();
    for (Task__c t : [
        SELECT Project__c, Status__c, End_Date__c
        FROM Task__c
        WHERE Project__c IN :projectIdSet
      ]) {
      List<Task__c> bucket = tasksByProjectId.get(t.Project__c);
      if (bucket == null) {
        bucket = new List<Task__c>();
        tasksByProjectId.put(t.Project__c, bucket);
      }
      bucket.add(t);
    }

    List<Project__c> projectsToUpdate = new List<Project__c>();

    for (Id projectId : projectsById.keySet()) {
      Project__c currentProject = projectsById.get(projectId);
      List<Task__c> projectTasks = tasksByProjectId.get(projectId);
      if (projectTasks == null) {
        projectTasks = new List<Task__c>();
      }

      String targetStatus = ToDoListService.getParentStatus(projectTasks, currentProject.Planed_End_Date__c);

      if (currentProject.Status__c != targetStatus) {
        projectsToUpdate.add(new Project__c(
          Id = projectId,
          Status__c = targetStatus
        ));
      }
    }

    if (!projectsToUpdate.isEmpty()) {
      update projectsToUpdate;
    }
  }
}
