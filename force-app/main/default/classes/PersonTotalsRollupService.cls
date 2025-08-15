public with sharing class PersonTotalsRollupService {

  public static void recalculateTotalsForPersons(Set<Id> personIdSet) {
    if (personIdSet == null || personIdSet.isEmpty()) {
      return;
    }

    Map<Id, Integer> taskCountByPersonId = new Map<Id, Integer>();
    for (AggregateResult aggregateRow : [
        SELECT Person__c PersonId, COUNT(Id) TaskCount
        FROM Task__c
        WHERE Person__c IN :personIdSet
        GROUP BY Person__c
    ]){
        Id personId = (Id) aggregateRow.get('PersonId');
        Integer taskCount = (Integer) aggregateRow.get('TaskCount');
        taskCountByPersonId.put(personId, taskCount);
      }

    Map<Id, Integer> projectCountByPersonId = new Map<Id, Integer>();
    for (AggregateResult aggregateRow : [
        SELECT Person__c PersonId, COUNT(Id) ProjectCount
        FROM Project__c
        WHERE Person__c IN :personIdSet
        GROUP BY Person__c
    ]) {
        Id personId = (Id) aggregateRow.get('PersonId');
        Integer projectCount = (Integer) aggregateRow.get('ProjectCount');
        projectCountByPersonId.put(personId, projectCount);
    }

    List<Person__c> personsToUpdate = new List<Person__c>();
    for (Id personId : personIdSet) {
      Integer taskCount    = taskCountByPersonId.containsKey(personId)    ? taskCountByPersonId.get(personId)    : 0;
      Integer projectCount = projectCountByPersonId.containsKey(personId) ? projectCountByPersonId.get(personId) : 0;

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
    if (newRecordList != null) for (Task__c taskRecord : newRecordList) personIdSet.add(taskRecord.Person__c);
    if (oldRecordList != null) for (Task__c taskRecord : oldRecordList) personIdSet.add(taskRecord.Person__c);
    personIdSet.remove(null);
    return personIdSet;
  }

  public static Set<Id> collectPersonIdsFromProjectRecords(List<Project__c> newRecordList, List<Project__c> oldRecordList) {
    Set<Id> personIdSet = new Set<Id>();
    if (newRecordList != null) for (Project__c projectRecord : newRecordList) personIdSet.add(projectRecord.Person__c);
    if (oldRecordList != null) for (Project__c projectRecord : oldRecordList) personIdSet.add(projectRecord.Person__c);
    personIdSet.remove(null);
    return personIdSet;
  }
}
