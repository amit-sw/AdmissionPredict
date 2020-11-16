//
//  ContentView.swift
//  AdmissionPredict
//
//  Created by Amit Gupta on 11/10/20.
//

import SwiftUI
import CoreML

import Alamofire
import SwiftyJSON
//import Alamofire

// This is for predicting battery life https://aiclub.world/projects/32e764d4-0b61-4c36-bce9-2cb85903cc33?tab=service

struct ContentView: View {
    @State var prediction: String = "I don't know yet"
    
    var aiSource=["Local","Server"]
    @State var selectedAISource=1
    @State var localAIsource = true
    
    @State var params: Parameters = [:]
    @State var greScore: Float = 315
    @State var toeflScore: Float = 106
    @State var universityRating: Int = 3
    @State var sopValue: Int = 3
    @State var lorValue: Int = 3
    @State var cgpaValue: Float = 8.36
    @State var researchValue: Int = 1
    
    @State var mostUsedApp = 0
    @State var secondMostUsedApp = 1
    @State var startingTime = "11:19"
    @State var continuousUse = 0
    @State var brightness = 0
    
    let minCgpa=6.0, maxCgpa=10.0, minGre=290, maxGre=340, minToefl=90, maxToefl=120
    

    //let uploadURL = "https://0iugukheil.execute-api.us-east-1.amazonaws.com/Predict/aae3bafb-105e-4622-9078-c0987ddb88c2"
    let uploadURL = "https://4c9kil1hsi.execute-api.us-east-1.amazonaws.com/Predict/448d1e79-95c2-4535-bada-41843c7d7279"
    
    let appOptions = ["Safari", "Messaging","Other","Chrome","Youtube"]
    let useOptions = ["Yes","No"]
    let brightnessOptions = ["Full","Lowest","Half","High"]
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    /*
                    Picker(selection: $selectedAISource, label: Text("AI")) {
                        ForEach(0 ..< aiSource.count) {
                            Text(self.aiSource[$0])
                        }
                    }.onChange(of: selectedAISource, perform: { value in
                        predictAI()
                    })
                    */
                    
                    Toggle(isOn: $localAIsource) {
                          Text("On-device ML model")
                    }.onChange(of: localAIsource, perform: { value in
                        predictAI()
                    })

                }
                
                Section(header: Text("Inputs")) {
                    /*
                     HStack {
                     VStack {
                     Slider(value: $greScore, in: 0...20, step:1)
                     Text("Current slider value: \(greScore, specifier: "%.2f")")
                     }.padding()
                     }
                     */
                    /*
                    Stepper(value: $greScore,
                            in: 290...340,
                            label: {
                        Text("GRE Score: \(self.greScore)")
                            }).onChange(of: greScore, perform: { value in
                                predictAI()
                            })
                    Stepper(value: $toeflScore,
                            in: 90...120,
                            label: {
                        Text("TOEFL Score: \(self.toeflScore)")
                            }).onChange(of: toeflScore, perform: { value in
                                predictAI()
                            })
                    */
                    HStack {
                    VStack {
                        HStack {
                            Image(systemName: "minus")
                        Slider(value: $greScore, in: 290...340).onChange(of: greScore, perform: { value in
                            predictAI()
                        }).accentColor(Color.green)
                            Image(systemName: "plus")
                        }.foregroundColor(Color.green)
                    Text("GRE Score: \(greScore, specifier: "%.0f")")
                    }
                    }
                    HStack {
                    VStack {
                        HStack {
                            Image(systemName: "minus")
                        Slider(value: $toeflScore, in: 90...120).onChange(of: toeflScore, perform: { value in
                            predictAI()
                        }).accentColor(Color.green)
                            Image(systemName: "plus")
                        }.foregroundColor(Color.green)
                    Text("TOEFL Score: \(toeflScore, specifier: "%.0f")")
                    }
                    }
                    HStack {
                    VStack {
                        HStack {
                            Image(systemName: "minus")
                        Slider(value: $cgpaValue, in: 6...10).onChange(of: cgpaValue, perform: { value in
                            predictAI()
                        }).accentColor(Color.green)
                            Image(systemName: "plus")
                        }.foregroundColor(Color.green)
                    Text("CGPA: \(cgpaValue, specifier: "%.2f")")
                    }
                    }
                    Stepper(value: $universityRating,
                            in: 1...5,
                            label: {
                        Text("University Rating: \(self.universityRating)")
                    }).onChange(of: universityRating, perform: { value in
                        predictAI()
                    })
                    Stepper(value: $sopValue,
                            in: 1...5,
                            label: {
                        Text("SOP: \(self.sopValue)")
                            }).onChange(of: sopValue, perform: { value in
                                predictAI()
                            })
                    Stepper(value: $lorValue,
                            in: 1...5,
                            label: {
                        Text("LOR: \(self.lorValue)")
                    }).onChange(of: lorValue, perform: { value in
                        predictAI()
                    })
                    Stepper(value: $researchValue,
                            in: 0...1,
                            label: {
                        Text("Research Value: \(self.researchValue)")
                            }).onChange(of: researchValue, perform: { value in
                                predictAI()
                            })

                }
                
                
                Section {
                    HStack {
                        Text("Prediction:").font(.largeTitle)
                    
                    /*
                    Button(action: {
                        self.predictAI()
                    }) {
                        Text("Predict")
                            .font(.title)
                    }
 */
                    Spacer()
                    Text(prediction)
                }
                }
            }
            .navigationBarTitle(Text("Admit or No Admit"),displayMode: .inline)
        }.onAppear(perform: predictAI)
    }
    
    func predictAI() {
        /*
        if(selectedAISource==1) {
        predictAIServer()
        } else {
            predictAILocal()
        }
        */
        
        if(localAIsource) {
            predictAILocal()
        } else {
            predictAIServer()
        }
    }
    
    func predictAILocal() {
        do {
        let model = try MyTabularRegressorV001_1(configuration: MLModelConfiguration())
        let g=Double(greScore)
        let t=Double(toeflScore)
        let u=Double(universityRating)
        let s=Double(sopValue)
        let l=Double(lorValue)
        let c=Double(cgpaValue)
        let r=Double(researchValue)
        guard let modelOutput = try? model.prediction(GRE_Score: g, TOEFL_Score: t, University_Rating: u, SOP: s, LOR: l, CGPA: c, Research: r) else {
            print("Fatal error in local prediction")
            prediction="Error"
            return
        }


        print(modelOutput)
        let prob = modelOutput.Chance_of_Admit
        print("Model predicted prob:",prob)
        let st = prob*100
        prediction=String(format: "%.1f%%", st)
        } catch {
            print("Error in creating/calling local ML Model")
        }
        
    }
    
    func predictAIServer() {
        print("Just got the call to PredictAI()")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        params["GRE Score"] = String(greScore)
        params["TOEFL Score"] = String(toeflScore)
        params["University Rating"] = String(universityRating)
        params["SOP"] = String(sopValue)
        params["LOR"] = String(lorValue)
        params["CGPA"] = String(cgpaValue)
        params["Research"] = String(researchValue)
        
        // "GRE Score":337,"TOEFL Score":118,"":4,"SOP":4.5,"LOR":4.5,"CGPA":9.65,"Research":
        /*
         params["Most used App"] = appOptions[mostUsedApp]
         params["Second most used App"] = appOptions[secondMostUsedApp]
         params["Starting time"] = startingTime
         params["Continuous use"] = useOptions[continuousUse]
         params["Brightness"] = brightnessOptions[brightness]
         */
        
        debugPrint("Calling the AI service with parameters=",params)
        
        AF.request(uploadURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            
            //debugPrint("AF.Response:",response)
            switch response.result {
            case .success(let value):
                var json = JSON(value)
                //debugPrint("Initial value is ",value)
                //debugPrint("Initial JSON is ",json)
                let body = json["body"].stringValue
                //debugPrint("Initial Body is ",body)
                json = JSON.init(parseJSON: body)
                debugPrint("Second JSON is ",json)
                let predictedLabel = json["predicted_label"].stringValue
                //debugPrint("Predicted label equals",predictedLabel)
                let s = (Float(predictedLabel) ?? -0.01)*100
                self.prediction=String(format: "%.1f%%", s)
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
    
    init() {
        
        // UI look-and-feel
        UINavigationBar.appearance().backgroundColor = .yellow
        /*
         UINavigationBar.appearance().titleTextAttributes = [
         .foregroundColor: UIColor.darkGray,
         .font : UIFont(name:"HelveticaNeue", size: 30)!]
         */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

