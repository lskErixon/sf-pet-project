@isTest
public class TestCreatePerson {

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
  static void TestIsBlankFirstName(){
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
}