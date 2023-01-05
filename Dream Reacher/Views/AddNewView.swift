//
//  AddNewView.swift
//  Dream Reacher
//
//  Created by Julia Kansbod on 2022-12-11.
//

import SwiftUI

struct AddNewView: View {
    
    @EnvironmentObject var habitModel: HabitViewModel
    @Environment(\.self) var env
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 24){
                
                HStack {
                    
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName:"xmark.circle")
                    }
                    .tint(Color("Color-2"))
                    
                    Button {
                        if habitModel.deleteHabit(context: env.managedObjectContext){
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName:"trash")
                    }
                    .tint(.red)
                    .opacity(habitModel.editHabit == nil ? 0 : 1)
                    
                    Spacer()
                    
                    Text(habitModel.editHabit != nil ? "Edit Goal" : "Add New Goal")
                        .font(Font.custom("JosefinSans-Medium", size: 25))
                    
                    Spacer()
                    
                    Button("Add"){
                        Task{
                            if await habitModel.addHabit(context: env.managedObjectContext){
                                env.dismiss()
                            }
                        }
                    }
                    .tint(Color("Color-2"))
                    .disabled(!habitModel.doneStatus())
                    .opacity(habitModel.doneStatus() ? 1 : 0.6)
                    
                }
                .padding(.top, 30)
                
                TextField("What is your goal?", text: $habitModel.title)
                    .foregroundColor(Color("Black"))
                    .underlineTextField()
                    .font(Font.custom("JosefinSans", size: 17))
                
                //MARK: Colors
                HStack(spacing: 0){
                    ForEach(1...5, id: \.self) { index in
                        let color = "Color-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == habitModel.habitColor{
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            })
                            .onTapGesture {
                                withAnimation{
                                    habitModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                
                //MARK: Weekdays
                VStack(alignment: .leading, spacing: 6){
                    Text("Days of the week:")
                        .font(Font.custom("JosefinSans", size: 17))
                    
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack(spacing: 10){
                        ForEach(weekDays, id: \.self){ day in
                            let index = habitModel.weekDays.firstIndex { value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2)) //Bara två första bokstäverna av "monday" osv.
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background{
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(habitModel.habitColor) : Color("Blue").opacity(0.1))
                                }
                                .onTapGesture {
                                    withAnimation{
                                        if index != -1{
                                            habitModel.weekDays.remove(at: index)
                                        }else{
                                            habitModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                
                //MARK: Notifications
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text("Reminders")
                            .font(Font.custom("JosefinSans", size: 17))
                        Text("Set notifications for my goal.")
                            .font(Font.custom("JosefinSans", size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $habitModel.isReminderOn) {}
                        .labelsHidden()
                        .tint(Color(habitModel.habitColor))
                }
                .padding(.top, 15)
                .opacity(habitModel.notificationAccess ? 1 : 0)
                
                HStack(spacing: 12){
                    Label {
                        Text(habitModel.reminderDate.formatted(date: .omitted, time: .shortened))
                            .font(Font.custom("JosefinSans", size: 17))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical,12)
                    .onTapGesture{
                        withAnimation{
                            habitModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("Add notication text...", text: $habitModel.reminderText)
                        .font(Font.custom("JosefinSans", size: 17))
                        .padding(.horizontal)
                        .padding(.vertical,10)
                        .foregroundColor(Color("Black"))
                        .underlineTextField()
                }
                .frame(height: habitModel.isReminderOn ? nil : 0)
                .opacity(habitModel.isReminderOn ? 1 : 0)
                .opacity(habitModel.notificationAccess ? 1 : 0)
                
                
            }
            .animation(.easeInOut, value: habitModel.isReminderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)
            .padding(.horizontal, 30)
            .overlay{
                if habitModel.showTimePicker{
                    ZStack{
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                            .onTapGesture{
                                withAnimation{
                                    habitModel.showTimePicker.toggle()
                                }
                            }
                        
                        DatePicker.init("", selection: $habitModel.reminderDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            .padding()
                    }
                }
            }
            .background(Color("White"))
            .foregroundColor(Color("Black"))
            .tint(Color("Black"))
        }
        
    }
}

struct AddNewView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewView()
            .environmentObject(HabitViewModel())
    }
}

//MARK: Extension for textfield
extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(Color("Blue"))
            .padding(10)
    }
}
