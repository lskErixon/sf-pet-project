public with sharing class HighPriorityTaskAlertService {

  @future
  public static void sendAlertsAsync(List<Id> taskIdList) {
    if (taskIdList == null || taskIdList.isEmpty()) {
      return;
    } 
    Set<Id> taskIds = new Set<Id>(taskIdList);

    List<Task__c> tasks = [
      SELECT Id,
          Name,
          Person__c,
          Person__r.Name,
          Person__r.Email__c
      FROM Task__c
      WHERE Id IN :taskIds
    ];

    String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
    List<Messaging.SingleEmailMessage> batch = new List<Messaging.SingleEmailMessage>();

    for (Task__c task : tasks) {
      if (task.Person__r == null || String.isBlank(task.Person__r.Email__c)) {
        continue;
      } 

      String safeName = String.isBlank(task.Name) ? String.valueOf(task.Id) : task.Name;
      String recordUrl = baseUrl + '/' + task.Id;

      Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
      m.setToAddresses(new List<String>{ task.Person__r.Email__c });
      m.setSubject('High Priority Task Alert: ' + safeName);
      m.setPlainTextBody(
        'This task was marked as HIGH PRIORITY.' + '\n\n' +
        'Task: ' + safeName + '\n' +
        'Open the task: ' + recordUrl + '\n'
      );
      batch.add(m);
    }

    if (!batch.isEmpty()) {
      Messaging.sendEmail(batch, false);
    }
  }
}
