@isTest
public class TestDeleteProjects {

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
}
