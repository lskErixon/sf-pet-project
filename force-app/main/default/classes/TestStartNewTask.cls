@isTest
public class TestStartNewTask {
    
  @isTest
  static void testStartNewTask_WithNullPersonId_ShouldDoNothing() {
    Project__c project = TestDataFactory.createProject();
    ToDoListService.startNewTask(project.Id, null);
    List<Task__c> tasks = [SELECT Id FROM Task__c WHERE Project__c = :project.Id];
    System.assertEquals(0, tasks.size(), 'No task should be inserted if personId is null');
  }

  @isTest
  static void testStartNewTask_NullProjectId_ShouldNotInsertTask() {
    Person__c person = TestDataFactory.createPerson();
    ToDoListService.startNewTask(null, person.Id);
    List<Task__c> tasks = [SELECT Id FROM Task__c WHERE Person__c = :person.Id];
    System.assertEquals(0, tasks.size(), 'No task should be inserted if projectId is null');
  }

  @isTest 
  static void testStartNewTask_WithValidInput_ShouldInsertTask() {
    Project__c project = TestDataFactory.createProject();
    Person__c person = TestDataFactory.createPerson();

    Test.startTest();
    ToDoListService.startNewTask(project.Id, person.Id);
    Test.stopTest();

    List<Task__c> tasks = [
        SELECT Id, Project__c, Person__c, Start_Date__c, Status__c
        FROM Task__c
        WHERE Project__c = :project.Id AND Person__c = :person.Id
    ];
    System.assertEquals(1, tasks.size(), 'Task should have been inserted');
  }
  
  
}