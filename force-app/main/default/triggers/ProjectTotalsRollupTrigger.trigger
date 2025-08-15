trigger ProjectTotalsRollupTrigger on Project__c (
    after insert, after update, after delete, after undelete
) {
    new ProjectTotalsRollupHandler().run();
}