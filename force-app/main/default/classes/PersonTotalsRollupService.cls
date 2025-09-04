public with sharing class PersonTotalsRollupService {

  public static void recalculateTotalsForPersons(Set<Id> personIdSet) {
    if (personIdSet == null || personIdSet.isEmpty()) {
        return;
    }

    List<Task__c> taskList = [
      SELECT Person__c, Project__c
      FROM Task__c
      WHERE Person__c IN :personIdSet
    ];

    Map<Id, Integer> taskCountByPersonId = new Map<Id, Integer>();
    Map<Id, Set<Id>> projectIdSetByPersonId = new Map<Id, Set<Id>>();

    for (Task__c taskRecord : taskList) {
      Id personId = taskRecord.Person__c;
      if (personId == null) { 
        continue;
      }

      Integer currentTaskCount = taskCountByPersonId.get(personId);
      taskCountByPersonId.put(personId, (currentTaskCount == null ? 1 : currentTaskCount + 1));

      if (taskRecord.Project__c != null) {
        Set<Id> projectSet = projectIdSetByPersonId.get(personId);
        if (projectSet == null) {
          projectSet = new Set<Id>();
          projectIdSetByPersonId.put(personId, projectSet);
        }
        projectSet.add(taskRecord.Project__c);
      }
    }

    List<Person__c> personsToUpdate = new List<Person__c>();
    for (Id personId : personIdSet) {
      Integer taskCount = taskCountByPersonId.containsKey(personId)
      ? taskCountByPersonId.get(personId) 
      : 0;

      Integer projectCount = projectIdSetByPersonId.containsKey(personId)
      ? projectIdSetByPersonId.get(personId).size()
      : 0;

      personsToUpdate.add(new Person__c(
        Id = personId,
        Total_Amount_Tasks__c    = taskCount,
        Total_Amount_Projects__c = projectCount
      ));
    }

    if (!personsToUpdate.isEmpty()) {
      update personsToUpdate;
    }
  }

  public static Set<Id> collectPersonIdsFromTaskRecords(List<Task__c> newRecordList, List<Task__c> oldRecordList) {
    Set<Id> personIdSet = new Set<Id>();
    if (newRecordList != null) {
      for (Task__c taskRecord : newRecordList) {
          personIdSet.add(taskRecord.Person__c);
      }
    }
    if (oldRecordList != null) {
      for (Task__c taskRecord : oldRecordList) {
        personIdSet.add(taskRecord.Person__c);
      }
    }
    return personIdSet;
  }
}
