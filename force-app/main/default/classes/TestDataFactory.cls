@IsTest
public class TestDataFactory {
    
  public static Project__c createProject() {
    Project__c proj = new Project__c(
      Name = 'Test Project ' + String.valueOf(Math.abs(Crypto.getRandomInteger())),
      Start_Date__c = Date.today().addDays(-5),
      Planed_End_Date__c   = Date.today().addDays(5)
    );
    insert proj;
    return proj;
  }

  public static Project__c createProject(String name, Date startDate, Date endDate) {
    Project__c proj = new Project__c(
      Name = name,
      Start_Date__c = startDate,
      Planed_End_Date__c   = endDate
    );
    insert proj;
    return proj;
  }

  public static Person__c createPerson() {
    Person__c p = new Person__c(
      First_Name__c = 'First' + String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0,4),
      Last_Name__c  = 'Last'  + String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0,4) 
    );
    insert p;
    return p;
  }
    
  public static Person__c createPerson(String firstName, String lastName) {
    Person__c p = new Person__c(
      First_Name__c = firstName,                         
      Last_Name__c  = lastName                           
    );
    insert p;                                                  
    return p;                                                  
  }

  public static Task__c createTask(
    Id projectId,
    Id personId,
    String status,
    Date startDate,
    Date endDate)
  {
    Task__c t = new Task__c(
      Project__c    = projectId,
      Person__c     = personId,
      Status__c     = status,
      Start_Date__c = startDate,
      End_Date__c   = endDate,
      Label__c      = 'TestLabel' + String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0, 4)
    );
    insert t;
    return t;
  }

  public static Task__c createTask(Id projectId, Id personId) {
    return createTask(
      projectId,                                             
      personId,                   
        'Draft',                                           
        Date.today(),
      null
    );
  }

  public static List<Task__c> createTasksForProject(
    Project__c project,
    Person__c person,
    Integer count
    )
  {
    List<String> statusOptions = new List<String>{
      'Draft',
      'Started',
      'Completed'
    };
    List<Task__c> tasks = new List<Task__c>();
    for (Integer i = 0; i < count; i++) {
      String statusValue = statusOptions[Math.mod(i, statusOptions.size())];
      tasks.add(new Task__c(
        Project__c    = project.Id,
        Person__c     = person.Id,
        Status__c     = statusValue,
        Start_Date__c = Date.today().addDays(-i),
        End_Date__c   = Date.today().addDays(i),
        Label__c      = 'TestLabel' + String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0, 4)
      ));
    }
    insert tasks;
    return tasks;
  }
}