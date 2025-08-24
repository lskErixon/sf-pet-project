trigger TaskProjectStatusTrigger on Task__c (after insert, after update) {
  new ProjectStatusFromTasksHandler().run();
}
