//
//  HabitViewModel.swift
//  Dream Reacher
//
//  Created by Julia Kansbod on 2022-12-11.
//

import SwiftUI
import CoreData
import UserNotifications

class HabitViewModel: ObservableObject {
    
    @Published var addNewHabit: Bool = false
    
    @Published var title: String = ""
    @Published var habitColor: String = "Color-5"
    @Published var weekDays: [String] = []
    @Published var isReminderOn: Bool = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date = Date()
    
    //Reminder Time Picker
    @Published var showTimePicker: Bool = false
    
    //Editing Habit
    @Published var editHabit: Habit?
    
    //Adding Habit to database
    func addHabit(context: NSManagedObjectContext)async -> Bool{
    
        var habit: Habit!
        if let editHabit = editHabit {
            habit = editHabit //om vi är inne och redigerar så aktiveras editHabit, annars görs en vanlig ny habit.
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? []) //Tar bort alla pending notifikationer
        } else {
            habit = Habit(context: context)
        }
        
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isReminderOn = isReminderOn
        habit.reminderText = reminderText
        habit.notificationDate = reminderDate
        habit.notificationIDs = []
        
        if isReminderOn{
            //Scheduling notifications and adding and saving data
            if let ids = try? await scheduleNotification(){
                habit.notificationIDs = ids
                if let _ = try? context.save(){
                    return true
                }
            }
        } else{
            //Adding and saving data
            if let _ = try? context.save(){
                return true
            }
        }
        
        return false
    }
    
    //Notification Access status
    @Published var notificationAccess: Bool = false
    
    init(){
        requestNotificationAccess()
    }
    
    func requestNotificationAccess(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    //Adding notifications
    func scheduleNotification()async throws->[String]{
        
        let content = UNMutableNotificationContent()
        content.title = "Goalery"
        content.body = reminderText
        content.sound = UNNotificationSound.default
        //Scheduled IDs
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.weekdaySymbols
        //Scheduling Notification
        for weekDay in weekDays{
            //Unique ID for each notification
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: reminderDate)
            let min = calendar.component(.minute, from: reminderDate)
            let day = weekdaySymbols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1

            if day != -1{
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1 //Since week day starts from 1-7, we add +1 to index.
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true) //Will trigger notification on each selected day.
                
                //Notification request:
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
                //Adding ID:
                notificationIDs.append(id)
            }
        }
        
        return notificationIDs
        
    }
    
    //Erasing all content from database
    func resetData(){
        title = ""
        habitColor = "Color-5"
        weekDays = []
        isReminderOn = false
        reminderDate = Date()
        reminderText = ""
        editHabit = nil
    }
    
    //Deleting Data from Database
    func deleteHabit(context: NSManagedObjectContext)->Bool{
        if let editHabit = editHabit{
            if editHabit.isReminderOn{
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? []) //Tar bort alla pending notifikationer
            }
            context.delete(editHabit)
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    //Restoring Edit Data
    func restoreEditData(){
        if let editHabit = editHabit{
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "Color-5"
            weekDays = editHabit.weekDays ?? []
            isReminderOn = editHabit.isReminderOn
            reminderDate = editHabit.notificationDate ?? Date()
            reminderText = editHabit.reminderText ?? ""
        }
    }
    
    //Done Button Status, används för att man inte ska kunna trycka i "done"-knappen om inte alla rätta fält är ifyllda.
    func doneStatus()-> Bool {
        let reminderStatus = isReminderOn ? reminderText == "" : false
        if title == "" || weekDays.isEmpty || reminderStatus{
            return false
        }
        return true
    }
}

