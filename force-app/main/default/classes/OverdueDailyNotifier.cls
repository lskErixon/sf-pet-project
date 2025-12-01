public with sharing class OverdueDailyNotifier implements Queueable {

  private static final String STATUS_COMPLEETED = 'Completed';

  public void execute(QueueableContext context) {
    List<Task__c> overdueTasks = [
      SELECT Id, Name, Label__c, End_Date__c, Status__c, Person__r.Email__c
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
    sendMail(overdueTasks);
  }

  private void sendMail(List<Task__c> overdueTasks) {
    List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

    for (Task__c task : overdueTasks) {
      String recipientEmail = task.Person__r.Email__c;
      if (String.isBlank(recipientEmail)) {
        continue;
      }

      Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
      emailMessage.setToAddresses(new String[] { recipientEmail });
      emailMessage.setSubject('Overdue Task: ' + (task.Label__c == null ? task.Name : task.Label__c));
      emailMessage.setPlainTextBody(
        'Hello,' +
        '\n\nThis is a reminder that your task is overdue.' +
        '\nLabel: ' + (task.Label__c == null ? '(no label)' : task.Label__c) +
        '\nEnd date: ' + String.valueOf(task.End_Date__c) +
        '\nStatus: ' + String.valueOf(task.Status__c) +
        '\n\nPlease review or update this task as soon as possible.' +
        '\n\n-- Automated Daily Reminder System'
      );
      emailMessages.add(emailMessage);
    }

    if (!emailMessages.isEmpty()) {
      Messaging.sendEmail(emailMessages, false);
    }
  }
}
