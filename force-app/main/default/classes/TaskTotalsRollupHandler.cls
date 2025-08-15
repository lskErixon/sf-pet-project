public with sharing class TaskTotalsRollupHandler extends TriggerHandler {

  public override void afterInsert() { runRecalculationForAffectedPersons(Trigger.new, null); }
  public override void afterUpdate() { runRecalculationForAffectedPersons(Trigger.new, Trigger.old); }
  public override void afterDelete() { runRecalculationForAffectedPersons(null, Trigger.old); }
  public override void afterUndelete() { runRecalculationForAffectedPersons(Trigger.new, null); }

  private void runRecalculationForAffectedPersons(List<SObject> newRecordList, List<SObject> oldRecordList) {
    Set<Id> personIdSet = new Set<Id>();
      if (newRecordList != null) {
        personIdSet.addAll(
        PersonTotalsRollupService.collectPersonIdsFromTaskRecords((List<Task__c>) newRecordList, null)
      );
    }
    if (oldRecordList != null) {
      personIdSet.addAll(
        PersonTotalsRollupService.collectPersonIdsFromTaskRecords(null, (List<Task__c>) oldRecordList)
      );
    }
    PersonTotalsRollupService.recalculateTotalsForPersons(personIdSet);
  }
}
