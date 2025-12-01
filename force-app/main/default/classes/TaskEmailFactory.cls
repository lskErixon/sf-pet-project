public with sharing class TaskEmailFactory {
  public static final String SUBJECT_OVERDUE = 'Overdue Task: ';
  public static final String SUBJECT_HIGH_PRIORITY = 'High Priority Task Alert: ';
  public static final String SUBJECT_DAILY_REMINDER_PREFIX = 'Daily Task Reminder: ';
  public static final String LABEL_NO_LABEL = '(no label)';
  public static final String LABEL_NO_PROJECT = '(no project)';
  public static final String PRIORITY_TAG_HIGH = '[HIGH] ';
  public static final String FIELD_LABEL = 'Label: ';
  public static final String FIELD_END_DATE = 'End date: ';
  public static final String FIELD_STATUS = 'Status: ';
  public static final String FIELD_PROJECT = 'Project: ';
  public static final String FIELD_DUE = ' — Due: ';

  public static final String HEADER_DAILY_REMINDER = 'Hello,' +
    '\n\nHere is your consolidated list of tasks due within the next 24 hours:' + '\n';
  public static final String HEADER_OVERDUE = 'Hello,' + 
    '\n\nThis is a reminder that your task is overdue.';
  public static final String HEADER_HIGH_PRIORITY =
      'This task was marked as HIGH PRIORITY.' + '\n\n';
  public static final String FOOTER_DAILY =
      '\n\nPlease review or update your tasks as needed.' +
      '\n\n— Automated Daily Task Reminder';
  public static final String FOOTER_OVERDUE =
      '\n\nPlease review or update this task as soon as possible.' +
      '\n\n-- Automated Daily Reminder System';

  public static Messaging.SingleEmailMessage buildOverdueTaskEmail(Task__c task) {
    if (task == null || task.Person__r == null || String.isBlank(task.Person__r.Email__c)) {
      return null;
    }
    String safeLabel = (task.Label__c == null ? LABEL_NO_LABEL : task.Label__c);

    String subject =
      SUBJECT_OVERDUE +
      (task.Label__c == null ? task.Name : task.Label__c);

    String body =
            HEADER_OVERDUE +
            '\n' +
            '\n' + FIELD_LABEL + safeLabel +
            '\n' + FIELD_END_DATE + String.valueOf(task.End_Date__c) +
            '\n' + FIELD_STATUS + String.valueOf(task.Status__c) +
            FOOTER_OVERDUE;

    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setToAddresses(new String[] { task.Person__r.Email__c });
    msg.setSubject(subject);
    msg.setPlainTextBody(body);
    return msg;
  }

  public static Messaging.SingleEmailMessage buildHighPriorityAlertEmail(Task__c task, String baseUrl) {
    if (task == null || task.Person__r == null || String.isBlank(task.Person__r.Email__c)) {
      return null;
    }

    String safeName = String.isBlank(task.Name) ? String.valueOf(task.Id) : task.Name;
    String recordUrl = baseUrl + '/' + task.Id;

    String subject =
      SUBJECT_HIGH_PRIORITY + safeName;

    String body =
      HEADER_HIGH_PRIORITY +
      'Task: ' + safeName + '\n' +
      'Open the task: ' + recordUrl + '\n';

      Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
      msg.setToAddresses(new List<String>{ task.Person__r.Email__c });
      msg.setSubject(subject);
      msg.setPlainTextBody(body);
      return msg;
    }

  public static Messaging.SingleEmailMessage buildDailyReminderEmail(String recipientEmail, List<Task__c> tasks) {
    if (String.isBlank(recipientEmail) || tasks == null || tasks.isEmpty()) {
      return null;
    }

    String subject =
      SUBJECT_DAILY_REMINDER_PREFIX + tasks.size() + ' task(s) due in 24h';

    String body = buildDailyReminderBody(tasks);

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new String[] { recipientEmail });
    email.setSubject(subject);
    email.setPlainTextBody(body);
    return email;
  }

  private static String buildDailyReminderBody(List<Task__c> tasks) {
    String header = HEADER_DAILY_REMINDER;
    String lines = '';

    for (Task__c task : tasks) {
      String priorityTag = task.High_Priority__c ? PRIORITY_TAG_HIGH : '';
      String label = (task.Label__c == null ? LABEL_NO_LABEL : task.Label__c);
      String projectName =
        (task.Project__r != null ? task.Project__r.Name : LABEL_NO_PROJECT);

      lines += '\n- ' +
      priorityTag + label +
      FIELD_DUE + String.valueOf(task.End_Date__c) +
      ' — Project: ' + projectName;
    }
    return header + lines + FOOTER_DAILY;
  }
}
