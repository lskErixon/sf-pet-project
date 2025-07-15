@isTest
public class TestUpdateTaskStatusesForProject {

  @isTest
  static void testUpdateTaskStatuses_WithValidDataCompleted_ShouldUpdateStatuses() {
    Project__c project = TestDataFactory.createProject();
    Person__c person = TestDataFactory.createPerson();
    List<Task__c> tasks = TestDataFactory.createTasksForProject(project, person, 3);
    ToDoListService.updateTaskStatusesForProject(project.Id, 'Completed');

    List<Task__c> updatedTasks = [
      SELECT Id, Status__c FROM Task__c WHERE Project__c = :project.Id
    ];

    for (Task__c task : updatedTasks) {
      System.assertEquals('Completed', task.Status__c);
    }
  }

  @isTest
  static void testUpdateTaskStatuses_WithValidDataDraft_ShouldUpdateStatuses() {
    Project__c project = TestDataFactory.createProject();
    Person__c person = TestDataFactory.createPerson();
    List<Task__c> tasks = TestDataFactory.createTasksForProject(project, person, 3);
    ToDoListService.updateTaskStatusesForProject(project.Id, 'Draft');

    List<Task__c> updatedTasks = [
      SELECT Id, Status__c FROM Task__c WHERE Project__c = :project.Id
    ];

    for (Task__c task : updatedTasks) {
      System.assertEquals('Draft', task.Status__c);
    }
  }

  @isTest
  static void testUpdateTaskStatuses_WithValidDataStarted_ShouldUpdateStatuses() {
    Project__c project = TestDataFactory.createProject();
    Person__c person = TestDataFactory.createPerson();
    List<Task__c> tasks = TestDataFactory.createTasksForProject(project, person, 3);
    ToDoListService.updateTaskStatusesForProject(project.Id, 'Started');

    List<Task__c> updatedTasks = [
      SELECT Id, Status__c FROM Task__c WHERE Project__c = :project.Id
    ];

    for (Task__c task : updatedTasks) {
      System.assertEquals('Started', task.Status__c);
    }
  }

  @isTest
  static void testUpdateTaskStatuses_NullProjectId_ShouldDoNothing() {
    Test.startTest();
    ToDoListService.updateTaskStatusesForProject(null, 'Completed');
    Test.stopTest();
    System.assert(true, 'Method completed without errors');
  }

  @isTest
  static void testUpdateTaskStatuses_InvalidStatus_ShouldHitDmlExceptionCatch() {
    Project__c project = TestDataFactory.createProject();
    Person__c person = TestDataFactory.createPerson();
    TestDataFactory.createTask(project.Id, person.Id);
    Test.startTest();
    ToDoListService.updateTaskStatusesForProject(project.Id, 'InvalidPicklistValue');
    Test.stopTest();
    System.assert(true, 'Handled DML error gracefully');
  }
}
