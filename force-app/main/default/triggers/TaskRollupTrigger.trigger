trigger TaskRollupTrigger on Task__c (
  after insert, after update, after delete, after undelete) {
  new TaskTotalsRollupHandler().run();
}
