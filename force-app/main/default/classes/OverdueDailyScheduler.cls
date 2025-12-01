global class OverdueDailyScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        System.enqueueJob(new OverdueDailyNotifier());
    }
}
