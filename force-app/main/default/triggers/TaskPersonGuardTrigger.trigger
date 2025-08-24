trigger TaskPersonGuardTrigger on Task__c (before update) {
    new TaskPersonGuardHandler().run();
}
