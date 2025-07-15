@IsTest
private class TestGetParentStatus {
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
}
