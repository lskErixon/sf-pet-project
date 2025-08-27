public with sharing class TaskTotalsRollupHandler extends TriggerHandler {

  public override void afterInsert() { runRecalc(Trigger.new, Trigger.old); }
  public override void afterUpdate() { runRecalc(Trigger.new, Trigger.old); }
  public override void afterDelete() { runRecalc(Trigger.new, Trigger.old); }
  public override void afterUndelete() { runRecalc(Trigger.new, Trigger.old); }

  private void runRecalc(List<SObject> newList, List<SObject> oldList) {
    Set<Id> affectedPersonIds = new Set<Id>();
    if (newList != null) {
      affectedPersonIds.addAll(
        PersonTotalsRollupService.collectPersonIdsFromTaskRecords((List<Task__c>) newList, null)
      );
    }
    if (oldList != null) {
      affectedPersonIds.addAll(
        PersonTotalsRollupService.collectPersonIdsFromTaskRecords(null, (List<Task__c>) oldList)
      );
    }
    PersonTotalsRollupService.recalculateTotalsForPersons(affectedPersonIds);
  }
}
