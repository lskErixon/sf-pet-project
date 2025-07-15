Date projectPlannedEndDate = Date.today().addDays(7);

List<Task__c> tasks = new List<Task__c>{
    new Task__c(Status__c = 'Draft'),
    new Task__c(Status__c = 'Draft')
};
System.debug('Scenario 1 (All Draft) -> ' 
    + ToDoListService.getParentStatus(tasks, projectPlannedEndDate));

tasks = new List<Task__c>{
    new Task__c(Status__c = 'Draft'),
    new Task__c(Status__c = 'Started'),
    new Task__c(Status__c = 'Draft')
};
System.debug('Scenario 2 (Any Started) -> ' 
    + ToDoListService.getParentStatus(tasks, projectPlannedEndDate));

tasks = new List<Task__c>{
    new Task__c(Status__c = 'Completed', End_Date__c = projectPlannedEndDate.addDays(-1)),
    new Task__c(Status__c = 'Completed', End_Date__c = projectPlannedEndDate)
};
System.debug('Scenario 3 (All Completed In Time) -> ' 
    + ToDoListService.getParentStatus(tasks, projectPlannedEndDate));

tasks = new List<Task__c>{
    new Task__c(Status__c = 'Completed', End_Date__c = projectPlannedEndDate.addDays(1))
};
System.debug('Scenario 4 (All Completed With Delay) -> ' 
    + ToDoListService.getParentStatus(tasks, projectPlannedEndDate));

tasks = new List<Task__c>{
    new Task__c(Status__c = 'Draft'),
    new Task__c(Status__c = 'Completed', End_Date__c = projectPlannedEndDate.addDays(-1))
};
System.debug('Scenario 5 (Mixed Draft+Completed) -> '
    + ToDoListService.getParentStatus(tasks, projectPlannedEndDate));
