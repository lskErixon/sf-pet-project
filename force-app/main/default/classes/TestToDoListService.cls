@isTest
public class TestToDoListService {

  @isTest
  static void testCreatePerson_WithEmptyFirstName_ShouldNotInsert() {
    Boolean exceptionThrown = false;
    try {
      Person__c pFactory = TestDataFactory.createPerson('', 'Smith');
      ToDoListService.createPerson(pFactory.First_Name__c, pFactory.Last_Name__c);
    } catch (DmlException e) {
        exceptionThrown = true;
        System.assert(e.getMessage().contains('Required fields are missing: [First_Name__c]'));
    }
        System.assertEquals(true, exceptionThrown, 'Expected DmlException was not thrown');
  }

  @isTest
  static void testCreatePerson_WithEmptyLastName_ShouldNotInsert() {
    Boolean exceptionThrown = false;
    try {
      Person__c pFactory = TestDataFactory.createPerson('Smith', '');
      ToDoListService.createPerson(pFactory.First_Name__c, pFactory.Last_Name__c);
    } catch (DmlException e) {
        exceptionThrown = true;
        System.assert(e.getMessage().contains('Required fields are missing: [Last_Name__c]'));
    }
        System.assertEquals(true, exceptionThrown, 'Expected DmlException was not thrown');
  }

  @isTest 
  static void testInsertFirstNameAndLastName() {
    Test.startTest();
    Person__c pFactory = TestDataFactory.createPerson('testName1', 'testName2');
    ToDoListService.createPerson(pFactory.First_Name__c, pFactory.Last_Name__c);
    Person__c result = [
      SELECT First_Name__c, Last_Name__c 
      FROM Person__c 
      WHERE Id = :pFactory.Id
    ];
    Test.stopTest();
    System.assertEquals('testName1', result.First_Name__c);
    System.assertEquals('testName2', result.Last_Name__c);
  }

  @isTest
  static void TestIsBlankLastName(){
    Boolean exceptionThrown = false;
    try {
      ToDoListService.createPerson('test', '');
      Person__c result = [
        SELECT Last_Name__c
        FROM Person__c 
        WHERE First_Name__c = 'test'
      ];
    } catch (QueryException e) {
      exceptionThrown = true;
      System.assert(e.getMessage().contains('List has no rows for assignment to SObject'));
    }
    System.assertEquals(true, exceptionThrown, 'Expected QueryException was not thrown');
  }

  @isTest
  static void testIsBlankFirstName(){
    Boolean exceptionThrown = false;
    try {
      ToDoListService.createPerson('', 'test');
      Person__c result = [
        SELECT First_Name__c
        FROM Person__c 
        WHERE Last_Name__c = 'test'
      ];
    } catch (QueryException e) {
        exceptionThrown = true;
        System.assert(e.getMessage().contains('List has no rows for assignment to SObject'));
    }
    System.assertEquals(true, exceptionThrown, 'Expected QueryException was not thrown');
  }
  @isTest
  static void testDeleteProjects_WithEmptySet_ShouldDoNothing() {
    Test.startTest();
    ToDoListService.deleteProjects(new Set<Id>());
    Test.stopTest();
    System.assert(true, 'Method completed without exception on empty set');
  }

  @isTest
  static void testDeleteProjects_WithNullSet_ShouldDoNothing() {
    Test.startTest();
    ToDoListService.deleteProjects(null);
    Test.stopTest();
    System.assert(true, 'Method completed without exception on null input');
  }

  @isTest
  static void testDeleteProjects_WithValidIds_ShouldDelete() {
    Project__c proj1 = TestDataFactory.createProject();
    Project__c proj2 = TestDataFactory.createProject();
    Set<Id> ids = new Set<Id>{ proj1.Id, proj2.Id };

    Test.startTest();
    ToDoListService.deleteProjects(ids);
    Test.stopTest();

    List<Project__c> remaining = [SELECT Id FROM Project__c WHERE Id IN :ids];
    System.assertEquals(0, remaining.size(), 'Projects should be deleted');
  }

  @isTest
  static void testDeleteProjects_NonExistentId_ShouldNotFail() {
    Project__c proj = TestDataFactory.createProject();
    Id fakeId = Project__c.sObjectType.newSObject().Id;
    Set<Id> ids = new Set<Id>{ proj.Id, fakeId };

    Test.startTest();
    ToDoListService.deleteProjects(ids);
    Test.stopTest();

    List<Project__c> remaining = [SELECT Id FROM Project__c WHERE Id = :proj.Id];
    System.assertEquals(0, remaining.size(), 'Existing project should be deleted');
  }

  @isTest
  static void testDeleteProjects_OnlyNonExistentIds_ShouldNotFail() {
    Id fakeId1 = Project__c.sObjectType.newSObject().Id;
    Id fakeId2 = Project__c.sObjectType.newSObject().Id;
    Set<Id> ids = new Set<Id>{ fakeId1, fakeId2 };
    Test.startTest();
    ToDoListService.deleteProjects(ids);
    Test.stopTest();
    System.assert(true, 'Method completed without exception for non-existent IDs only');
  }

  @IsTest
    static void testFinishedWithDelay() {
        Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
        Person__c person = TestDataFactory.createPerson('John','Doe');
        Task__c task = TestDataFactory.createTask(proj.Id, person.Id, 'Completed', Date.today(), Date.today().addDays(11));
        Test.startTest();
        String status = ToDoListService.getParentStatus(new List<Task__c>{task}, proj.Planed_End_Date__c);
        Test.stopTest();
        System.assertEquals('Finished with Delay', status);
    }
    
    @IsTest
    static void testInsertTaskWithInvalidPicklistThrowsDmlException() {
      Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today());
      Person__c person = TestDataFactory.createPerson('John','Doe');

      Boolean exceptionThrown = false;

      try {
        TestDataFactory.createTask(proj.Id, person.Id, 'blabla', Date.today(), Date.today());
      } catch (DmlException e) {
        exceptionThrown = true;
        System.assert(e.getMessage().contains('bad value for restricted picklist'));
      }
        System.assertEquals(true, exceptionThrown, 'Expected DmlException was not thrown');
    }

    @IsTest
    static void testFinishedInTime() {
        Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
        Person__c person = TestDataFactory.createPerson('John','Doe');
        Task__c task = TestDataFactory.createTask(proj.Id, person.Id, 'Completed', Date.today(), Date.today().addDays(10));
        Test.startTest();
        String status = ToDoListService.getParentStatus(new List<Task__c>{task}, proj.Planed_End_Date__c);
        Test.stopTest();
        System.assertEquals('Finished in Time', status);
    }

        @IsTest
    static void testAtLeastOneWithDelay() {
        Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
        Person__c person = TestDataFactory.createPerson('John','Doe');
        Task__c t1 = TestDataFactory.createTask(proj.Id, person.Id, 'Completed', Date.today(), Date.today().addDays(10));
        Task__c t2 = TestDataFactory.createTask(proj.Id, person.Id, 'Completed', Date.today(), Date.today().addDays(11));
        Test.startTest();
        String status = ToDoListService.getParentStatus(new List<Task__c>{t2, t1}, proj.Planed_End_Date__c);
        Test.stopTest();
        System.assertEquals('Finished with Delay', status);
    }

    @IsTest
    static void testInProgress() {
        Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
        Person__c person = TestDataFactory.createPerson('John','Doe');
        Task__c task = TestDataFactory.createTask(proj.Id, person.Id, 'Started', Date.today(), Date.today().addDays(10));
        Test.startTest();
        String status = ToDoListService.getParentStatus(new List<Task__c>{task}, proj.Planed_End_Date__c);
        Test.stopTest();
        System.assertEquals('In Progress', status);
    }

    @IsTest
    static void testNullTaskList() {
      Test.startTest();
      String status = ToDoListService.getParentStatus(null, Date.today());
      Test.stopTest();
      System.assertEquals('Draft', status);
    }

    @IsTest
    static void testEmptyTaskList() {
      Test.startTest();
      String status = ToDoListService.getParentStatus(new List<Task__c>(), Date.today());
      Test.stopTest();
      System.assertEquals('Draft', status);
    }

    @IsTest
    static void testOnlyDraftTasks() {
      Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
      Person__c person = TestDataFactory.createPerson('John','Doe');
      Task__c task = TestDataFactory.createTask(proj.Id, person.Id);
      Test.startTest();
      String status = ToDoListService.getParentStatus(new List<Task__c>{task}, proj.Planed_End_Date__c);
      Test.stopTest();
      System.assertEquals('Draft', status);
    }

  @IsTest
  static void testMixedStatuses() {
    Project__c proj = TestDataFactory.createProject('Proj', Date.today(), Date.today().addDays(10));
    Person__c person = TestDataFactory.createPerson('John','Doe');
    List<Task__c> tasks = TestDataFactory.createTasksForProject(proj, person, 3);

    Test.startTest();
    String status = ToDoListService.getParentStatus(tasks, proj.Planed_End_Date__c);
    Test.stopTest();
    System.assertEquals('In Progress', status);
  }

  @IsTest
  static void testFallbackToDraftReturn() {
    Project__c proj = TestDataFactory.createProject('Mixed Project', Date.today(), Date.today().addDays(5));
    Person__c person = TestDataFactory.createPerson('Fallback', 'Case');

    Task__c t1 = TestDataFactory.createTask(proj.Id, person.Id, 'Draft', Date.today(), null);
    Task__c t2 = TestDataFactory.createTask(proj.Id, person.Id, 'Completed', Date.today(), Date.today());
    Test.startTest();
    String status = ToDoListService.getParentStatus(new List<Task__c>{ t1, t2 }, proj.Planed_End_Date__c);
    Test.stopTest();
    System.assertEquals('Draft', status, 'Fallback default DRAFT should be returned.');
  }

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