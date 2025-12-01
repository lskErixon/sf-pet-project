public with sharing class HighPriorityTaskAlertService {

  @future
  public static void sendAlertsAsync(List<Id> taskIdList) {
    if (taskIdList == null || taskIdList.isEmpty()) {
      return;
    }

    List<Task__c> tasks = [
      SELECT Id, Name, Person__c, Person__r.Email__c
      FROM Task__c
      WHERE Id IN :taskIdList
    ];

    String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Task__c task : tasks) {
      Messaging.SingleEmailMessage msg =
        TaskEmailFactory.buildHighPriorityAlertEmail(task, baseUrl);

      if (msg != null) {
        emails.add(msg);
      }
    }
    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails, false);
    }
  }
}
