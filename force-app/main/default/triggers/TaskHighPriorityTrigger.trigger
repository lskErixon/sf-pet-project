trigger TaskHighPriorityTrigger on Task__c (after insert, after update) {
  new TaskHighPriorityHandler().run();
}