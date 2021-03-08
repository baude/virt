//
//  ContentView.swift
//  virt
//
//  Created by Brent Baude on 3/6/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
        HStack {
            Button("Start") {
                doVirt()
            }
            Button("Stop"){
                exit(0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

func doVirt(){
    let memory = 1073741824
    let mc = NewMachineConfiguration(memory: memory, diskSize: 20)
    do {
        try mc.validate()
        let pm = PodmanMachine(mc: mc)
        try pm.configure()
        pm.openConsole()
        pm.start()


    }catch {
        NSLog("failed \(error)")
        exit(1)
    }

}
