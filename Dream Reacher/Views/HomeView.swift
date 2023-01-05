//
//  HomeView.swift
//  Dream Reacher
//
//  Created by Julia Kansbod on 2022-12-11.
//

import SwiftUI

struct HomeView: View {
    
    @State var date = Date()
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var habits: FetchedResults<Habit>
    
    @StateObject var habitModel: HabitViewModel = .init()
    
    var body: some View {
        
        ZStack{
            
            Image("bg")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            Color(.black)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.16)
            
            VStack(spacing: 24){
                HStack{
                    Text("Goalery.")
                        .font(Font.custom("JosefinSans-Bold", size: 20))
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    
                }
                
                ScrollView(showsIndicators: false){
                    
                    HStack{
                        
                        Spacer()
                        VStack(alignment: .trailing, spacing: 7){
                            Text(greeting())
                                .font(Font.custom("JosefinSans-Bold", size: 37))
                                .fontWeight(.bold)
                            Text(date.formatted(.dateTime.month(.wide).day()))
                            Text(date.formatted(.dateTime.weekday(.wide)))
                        }
                        .font(Font.custom("JosefinSans-Medium", size: 17))
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 20)
                    
                    if !habits.isEmpty{
                        HStack {
                            Text("My Current Goals")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("JosefinSans-Medium", size: 25))
                            
                            Button {
                                habitModel.addNewHabit.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .padding()
                                    .font(.headline)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.bottom, 20)
                        
                        ForEach(habits){ habit in
                            HabitCardView(habit: habit)
                        }
                        
                    } else {
                        
                        VStack{
                            Text("You have no current goals.")
                                .font(Font.custom("JosefinSans-Medium", size: 35))
                                .multilineTextAlignment(.center)
                                .padding(.top, 190)
                                .padding(.bottom, 270)
                            
                            Spacer()
                            
                            Button {
                                habitModel.addNewHabit.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .padding()
                                    .font(.headline)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .padding(.horizontal, 30)
            .foregroundColor(.white)
            .sheet(isPresented: $habitModel.addNewHabit) {
                habitModel.resetData()
            } content: {
                AddNewView()
                    .environmentObject(habitModel)
                    .presentationDetents([.medium, .large])
                    .background(Color("White"))
            }
        }
        
    }
    
    //MARK: Funktion för att skapa dynamisk hälsning beroende på vad klockan är.
    func greeting() -> String {
        var greet = ""
        
        let midNight0 = Calendar.current.date(bySettingHour: 0, minute: 00, second: 00, of: date)!
        let nightEnd = Calendar.current.date(bySettingHour: 3, minute: 59, second: 59, of: date)!
        let morningStart = Calendar.current.date(bySettingHour: 4, minute: 00, second: 0, of: date)!
        let morningEnd = Calendar.current.date(bySettingHour: 11, minute: 59, second: 59, of: date)!
        let noonStart = Calendar.current.date(bySettingHour: 12, minute: 00, second: 00, of: date)!
        let noonEnd = Calendar.current.date(bySettingHour: 16, minute: 59, second: 59, of: date)!
        let eveStart = Calendar.current.date(bySettingHour: 17, minute: 00, second: 00, of: date)!
        let eveEnd = Calendar.current.date(bySettingHour: 20, minute: 59, second: 59, of: date)!
        let nightStart = Calendar.current.date(bySettingHour: 21, minute: 00, second: 00, of: date)!
        let midNight24 = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        if ((date >= midNight0) && (nightEnd >= date)) {
            greet = "Good Night"
        } else if ((date >= morningStart) && (morningEnd >= date)) {
            greet = "Good Morning"
        } else if ((date >= noonStart) && (noonEnd >= date)) {
            greet = "Good Afternoon"
        } else if ((date >= eveStart) && (eveEnd >= date)) {
            greet = "Good Evening"
        } else if ((date >= nightStart) && (midNight24 >= date)) {
            greet = "Good night"
        }
        
        return greet
    }
    
    //MARK: Card View
    @ViewBuilder
    func HabitCardView(habit: Habit)->some View{
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .opacity(0.3)
                .background{
                    Color.white
                        .opacity(0.1)
                        .blur(radius: 10)
                }
                .padding(2)
                .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: 5)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            
            VStack(spacing: 6){
                HStack{
                    Text(habit.title ?? "")
                        .font(Font.custom("JosefinSans-Bold", size: 19))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.callout)
                        .foregroundColor(Color(habit.color ?? "Card-1"))
                        .scaleEffect(0.9)
                        .opacity(habit.isReminderOn ? 1 : 0)
                    
                    Spacer()
                    
                    let count = (habit.weekDays?.count ?? 0)
                    Text(count == 7 ? "Everyday" : "\(count) times a week")
                        .font(Font.custom("JosefinSans", size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal,10)
                .padding(.bottom, 15)
                
                let calendar = Calendar.current
                let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
                let symbols = calendar.weekdaySymbols
                let startDate = currentWeek?.start ?? Date()
                let activeWeekDays = habit.weekDays ?? []
                let activePlot = symbols.indices.compactMap{ index -> (String,Date) in
                    let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                    return (symbols[index],currentDate!)
                }
                
                HStack(spacing: 0){
                    ForEach(activePlot.indices, id: \.self){ index in
                        let item = activePlot[index]
                        
                        VStack(spacing: 6){
                            Text(item.0.prefix(3))
                                .font(Font.custom("JosefinSans", size: 13))
                                .foregroundColor(.gray)
                            
                            let status = activeWeekDays.contains { day in
                                return day == item.0
                            }
                            
                            Text(getDate(date: item.1))
                                .font(Font.custom("JosefinSans", size: 13))
                                .fontWeight(.semibold)
                                .padding(8)
                                .background{
                                    Circle()
                                        .fill(Color(habit.color ?? "Color-1"))
                                        .opacity(status ? 1 : 0)
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 1)
            }
            .padding(.vertical)
            .padding(.horizontal, 6)
            .onTapGesture {
                habitModel.editHabit = habit
                habitModel.restoreEditData()
                habitModel.addNewHabit.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        
    }
    
    func getDate(date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        return formatter.string(from: date)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
