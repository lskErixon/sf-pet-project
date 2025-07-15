public class ToDoListService {
  private final static String COMPLETED = 'Completed';
  private final static String STARTED = 'Started';
  private final static String DRAFT = 'Draft';
  private final static String IN_PROGRESS = 'In Progress';
  private static final String FINISHED_WITH_DELAY = 'Finished with Delay';
  private static final String FINISHED_IN_TIME = 'Finished in Time';
  private static final Integer ONLY_ONE = 1;

  public static String getParentStatus(List<Task__c> tasks, Date projectPlannedEndDate) {
    if (tasks == null || tasks.isEmpty()) {
      return DRAFT;
    }
    Set<String> statuses = new Set<String>();
    Boolean anyDelayed = false;

    for (Task__c task : tasks) {
      statuses.add(task.Status__c);
      if (task.Status__c == COMPLETED
        && task.End_Date__c != null
        && task.End_Date__c > projectPlannedEndDate) {
        anyDelayed = true;
      }
    }

    if (statuses.size() == ONLY_ONE && statuses.contains(DRAFT)) {
      return DRAFT;
    }
    if (statuses.contains(STARTED)) {
      return IN_PROGRESS;
    }
    if (statuses.size() == ONLY_ONE && statuses.contains(COMPLETED)) {
      return anyDelayed ? FINISHED_WITH_DELAY : FINISHED_IN_TIME;
    }
    return DRAFT;
  }

  public static void createPerson(String fName, String lName) {
      if (String.isBlank(fName) || String.isBlank(lName)) {
          return;
      }
      try {
        Person__c person = new Person__c(
          First_Name__c = fName,
          Last_Name__c  = lName
        );
        insert person;
      } catch (DmlException e) {
        throw new DmlException('Error inserting Person__c: ' + e.getMessage());
    }
  }

  public static void startNewTask(Id projectId, Id personId) {
    if (projectId == null || personId == null) {
        return;
    }
    try {
      Task__c task = new Task__c(
        Project__c    = projectId,
        Person__c     = personId,
        Start_Date__c = Date.today(),
        Status__c     = DRAFT,
        Label__c      = 'Auto-' + String.valueOf(DateTime.now().getTime()) //label d
      );
      System.debug('Created Task:' + task);
      insert task;
    } catch (DmlException e) {
      System.debug('Error inserting Task__c: ' + e.getMessage());
    }
  }

  public static void updateTaskStatusesForProject(Id projectId, String newStatus) {
    if (projectId == null || newStatus == null) {
      return;
    }
    try {
      List<Task__c> tasks = [SELECT Id, Status__c FROM Task__c WHERE Project__c = :projectId];
      for (Task__c task : tasks) {
        task.Status__c = newStatus;
      }
      update tasks;
    } catch (DmlException de) {
      System.debug('Error updating Task__c records: ' + de.getMessage());
    }
  }

  public static void deleteProjects(Set<Id> projectIds) {
    if (projectIds == null || projectIds.isEmpty()) {
      return;
    }
    try {
      List<Project__c> listOfProjects = [SELECT Id FROM Project__c WHERE Id IN :projectIds];
      delete listOfProjects;
    } catch (DmlException de) {
      System.debug('Error deleting Project__c records: ' + de.getMessage());
    }
  }
}