public with sharing class ProjectStatusFromTasksService {

  private static final String PROJECT_STATUS_DRAFT = 'Draft';
  private static final String PROJECT_STATUS_IN_PROGRESS = 'In Progress';
  private static final String PROJECT_STATUS_FINISHED_WITH_DELAY = 'Finished with Delay';
  private static final String PROJECT_STATUS_FINISHED_IN_TIME = 'Finished in Time';
  private static final String PROJECT_STATUS_ARCHIVED = 'Archived';

  private static final Map<String, Schema.SObjectField> STATUS_TO_TS_FIELD =
    new Map<String, Schema.SObjectField>{
        PROJECT_STATUS_DRAFT => Project__c.Draft_DateTime__c,
        PROJECT_STATUS_IN_PROGRESS => Project__c.In_Progress_DateTime__c,
        PROJECT_STATUS_FINISHED_IN_TIME => Project__c.Finished_In_Time_DateTime__c,
        PROJECT_STATUS_FINISHED_WITH_DELAY => Project__c.Finished_With_Delay_DateTime__c,
        PROJECT_STATUS_ARCHIVED => Project__c.Archived_DateTime__c
  };

  public static void recalculateForProjects(Set<Id> projectIdSet) {
    if (projectIdSet == null || projectIdSet.isEmpty()) return;
      
    Map<Id, Project__c> projectsById = new Map<Id, Project__c>([
      SELECT Id, Status__c, Planed_End_Date__c,
        Draft_DateTime__c, In_Progress_DateTime__c,
        Finished_In_Time_DateTime__c, Finished_With_Delay_DateTime__c,
        Archived_DateTime__c
      FROM Project__c
      WHERE Id IN :projectIdSet
    ]);
    if (projectsById.isEmpty()) return;

    Map<Id, List<Task__c>> tasksByProjectId = new Map<Id, List<Task__c>>();
      for (Task__c t : [
            SELECT Id, Project__c, Status__c, End_Date__c
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
      Project__c current = projectsById.get(projectId);
      Project__c updateRow = new Project__c(Id = projectId);
      Boolean shouldUpdate = false;

      if (current.Status__c == PROJECT_STATUS_ARCHIVED) {
        shouldUpdate = setFirstEntryTimestampIfEmpty(current, updateRow, PROJECT_STATUS_ARCHIVED) || shouldUpdate;
        if (shouldUpdate) projectsToUpdate.add(updateRow);
        continue;
      }

      List<Task__c> tasks = tasksByProjectId.get(projectId);
      if (tasks == null) tasks = new List<Task__c>();
      String newStatus = ToDoListService.getParentStatus(tasks, current.Planed_End_Date__c);

      if (current.Status__c != newStatus) {
        updateRow.Status__c = newStatus;
        shouldUpdate = true;
      }
      shouldUpdate = setFirstEntryTimestampIfEmpty(current, updateRow, newStatus) || shouldUpdate;

      if (shouldUpdate) projectsToUpdate.add(updateRow);
    }
    if (!projectsToUpdate.isEmpty()) {
      update projectsToUpdate;
    }
  }

  private static Boolean setFirstEntryTimestampIfEmpty(Project__c current, Project__c updateRow, String status) {
    Schema.SObjectField tsField = STATUS_TO_TS_FIELD.get(status);
    if (tsField == null) return false;

    Object hasValue = current.get(tsField);
    if (hasValue == null) {
        updateRow.put(tsField, System.now());
        return true;
    }
    return false;
  }

  public static Set<Id> collectProjectIdsFromTaskRecords(List<Task__c> newTaskList, List<Task__c> oldTaskList) {
    Set<Id> projectIdSet = new Set<Id>();
    if (newTaskList != null) for (Task__c t : newTaskList) projectIdSet.add(t.Project__c);
    if (oldTaskList != null) for (Task__c t : oldTaskList) projectIdSet.add(t.Project__c);
    projectIdSet.remove(null);
    return projectIdSet;
  }
}
