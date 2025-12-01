global class DailyTaskReminder implements Schedulable {

  global void execute(SchedulableContext context) {
    Date today = Date.today();
    Date tomorrow = today.addDays(1);

    List<Task__c> dueTasks = [
      SELECT Id, Name, Label__c, End_Date__c, High_Priority__c,
            Person__c, Person__r.Email__c, Project__c, Project__r.Name, Status__c
      FROM Task__c
      WHERE Person__c != null
        AND Person__r.Email__c != null
        AND Status__c != 'Completed'
        AND End_Date__c != null
        AND End_Date__c >= :today
        AND End_Date__c <= :tomorrow
      ORDER BY High_Priority__c DESC, End_Date__c ASC, Label__c ASC, Name ASC
    ];

    if (dueTasks.isEmpty()) {
      return;
    }

    Map<Id, List<Task__c>> tasksByPerson = new Map<Id, List<Task__c>>();
    for (Task__c task : dueTasks) {
      if (!tasksByPerson.containsKey(task.Person__c)) {
          tasksByPerson.put(task.Person__c, new List<Task__c>());
      }
      tasksByPerson.get(task.Person__c).add(task);
    }

    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    for (Id personId : tasksByPerson.keySet()) {
      List<Task__c> personTasks = tasksByPerson.get(personId);
      String recipientEmail = personTasks[0].Person__r.Email__c;

      String subject = 'Daily Task Reminder: ' + String.valueOf(personTasks.size()) + ' task(s) due in 24h';
      String body = buildEmailBody(personTasks);

      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new String[] { recipientEmail });
      email.setSubject(subject);
      email.setPlainTextBody(body);
      messages.add(email);
    }

    if (!messages.isEmpty()) {
      Messaging.sendEmail(messages, false);
    }
  }

  private static String buildEmailBody(List<Task__c> tasks) {
    String header = 'Hello,' 
    + '\n\nHere is your consolidated list of tasks due within the next 24 hours:' + '\n';
    String lines = '';
    for (Task__c task : tasks) {
        String priorityTag = task.High_Priority__c ? '[HIGH] ' : '';
        lines += '\n- ' + priorityTag + task.Label__c +
          ' — Due: ' + String.valueOf(task.End_Date__c) +
          ' — Project: ' + task.Project__r.Name;
    }
    String footer = '\n\nPlease review or update your tasks as needed.' 
                  + '\n\n— Automated Daily Task Reminder';
    return header + lines + footer;
  }
}
