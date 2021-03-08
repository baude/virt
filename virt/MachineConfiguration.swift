//
//  MachineConfiguration.swift
//  virt
//
//  Created by Brent Baude on 3/7/21.
//

import Foundation

/// Errors for interacting with machine configurations
enum MachineConfigurationError: Error{
    case insufficientMemory(needed: Int)
    case invalidConfiguration
}

/// machine configuration feeds a virtual machine
struct MachineConfiguration    {
    var name: String?
    var memory = 1073741824
    var diskSize = 20
    /// Validates the configuration provided for a vm
    ///   - Throws:
    ///       - `MachineConfigurationError.insufficientMemory`
    ///       if memory is less than 512MB
    func validate() throws         {
        print(self.memory)
        if self.memory < 512 {
            throw MachineConfigurationError.insufficientMemory(needed: 1073741824)
        }
    }
}

/// creates a new object of type MachineConfiguration
///   - Returns : `MachineConfiguration`
func NewMachineConfiguration(memory: Int, diskSize: Int) -> MachineConfiguration {
    var machineConfig = MachineConfiguration()
    machineConfig.diskSize = diskSize
    machineConfig.memory = memory
    NSLog("made it here")
    return machineConfig
}
