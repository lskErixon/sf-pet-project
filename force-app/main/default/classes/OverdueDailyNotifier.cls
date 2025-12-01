public with sharing class OverdueDailyNotifier implements Queueable {
  private static final String STATUS_COMPLEETED = 'Completed';

  public void execute(QueueableContext context) {
    List<Task__c> overdueTasks = [
      SELECT Id, Name, Label__c, End_Date__c, Status__c, Person__r.Email__c, Person__r.Id
      FROM Task__c
      WHERE Status__c != :STATUS_COMPLEETED
      AND End_Date__c != null
      AND End_Date__c < :Date.today()
      AND Person__r.Email__c != null
      LIMIT 200
    ];

    if (overdueTasks.isEmpty()) {
      return;
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Task__c task : overdueTasks) {
      Messaging.SingleEmailMessage msg = TaskEmailFactory.buildOverdueTaskEmail(task);
      if (msg != null) {
        emails.add(msg);
      }
    }
    
    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails, false);
    }
  }
}
