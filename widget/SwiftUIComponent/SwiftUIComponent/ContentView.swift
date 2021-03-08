//
//  ContentView.swift
//  SwiftUIComponent
//
//  Created by Geely on 2021/3/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // ButtonTapView()
        //TextFieldViewDemo()
        // PickViewDemo()
        //WeSpliceView() // 进行相应的视图操作
        // ZStackBackgroundViewDemo() //  这个
        ButtonViewDemo()
    }
}


struct ButtonViewDemo:View {
    var body: some View {
        Button(action: {
            print("Edit button was tapped")
        }) {
            VStack(spacing: 5) {
                Image(systemName: "pencil")
                Text("编辑")
            }
        }
    }
}

struct ZStackBackgroundViewDemo:View {
    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
            Text("Hello World")
        }
    }
}


struct ZStackViewDemo:View {
    var body: some View {
        ZStack {
            Text("Hello World")
            Text("This is inside a stack")
        }
    }
}

struct StackViewDemo:View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("hello world my life")
            Text("hello world my life riegttt")
            Spacer() // 自动占满剩余的空间
        }
    }
}




// 计算相应分数的
struct WeSpliceView: View {
    @State private var checkAmount = ""
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 2
    let tipPercentages = [10, 15, 20, 25, 0]
    // 计算属性
    var totalPerPerson: Double {
        // calculate the total per person here
        let peopleCount = Double(numberOfPeople + 2)
        let tipSelection = Double(tipPercentages[tipPercentage])
        
        let orderAmount = Double(checkAmount) ?? 0
        
        let tipValue = orderAmount / 100 * tipSelection
        
        let grandTotal = orderAmount + tipValue
       
        let amountPerPerson = grandTotal / peopleCount
        
        return amountPerPerson
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $checkAmount)
                        .keyboardType(.decimalPad)
                    Picker("Number of people", selection: $numberOfPeople) {
                            ForEach(2 ..< 100) {
                                Text("\($0) people")
                            }
                        }
                }

                Section(header: Text("How much tip do you want to leave?")) {
                   
                    Picker("Tip percentage", selection: $tipPercentage) {
                            ForEach(0 ..< tipPercentages.count) {
                                Text("\(self.tipPercentages[$0])%")
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Text("$\(totalPerPerson, specifier: "%.2f")")
                }
            }.navigationBarTitle("WeSplit")
        }
    }
    
}

struct PickViewDemo: View {
    let students = ["Harry", "Hermione", "Ron"]
        @State private var selectedStudent = 0

        var body: some View {
            VStack {
                Picker("Select your student", selection: $selectedStudent) {
                    ForEach(0 ..< students.count) {
                        Text(self.students[$0])
                    }
                }
                Text("You chose: Student \(students[selectedStudent])")
            }
        }
}

struct TextFieldViewDemo: View {
    @State private var name = ""
    @State private var phone = ""
    var body: some View {
            Form {
                HStack {
                    Text("姓名：")
                    TextField("cehi", text: $name)
                }
                Text("Your name is \(name)")
                HStack {
                    Text("电话号码：")
                    TextField("Enter your name", text: $phone)
                }
            }
    }
}

struct ButtonTapView: View {
    @State var tapCount = 0
    var body: some View {
        Button("Tap Count: \(tapCount)") {
            self.tapCount += 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
