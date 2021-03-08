//
//  VirtualMachine.swift
//  virt
//
//  Created by Brent Baude on 3/7/21.
//

import Foundation
import Virtualization
import Cocoa

/// Errors for interacting with virtual machines
enum VirtualMachineError: Error {
    case invalidStateToStart
    case invalidStateToStop
    case invalidConfiguration
    case unableToCreateVM
    case unableToStop
    case unableToStart
}


/// Podman machine represents the commands needed to manage
/// virtual machines.
class PodmanMachine :NSObject, VZVirtualMachineDelegate {
    //private var memorySize :UInt64
    private var mc :MachineConfiguration
    private var virtualMachine: VZVirtualMachine! = nil
    var readPipe = Pipe()
    var writePipe = Pipe()

    private lazy var consoleWindow: NSWindow = {
        let viewController = ConsoleViewController()
        viewController.configure(with: readPipe, writePipe: writePipe)
        return NSWindow(contentViewController: viewController)
    }()
   
    private lazy var consoleWindowController: NSWindowController = {
        let windowController = NSWindowController(window: consoleWindow)
        return windowController
    }()
   
    init(mc: MachineConfiguration){
        // todo: this needs to be simplified for when you have a name of the virtual machine
        // and you just want to start/stop it.  should just take name.  then second method
        // to create it.
        // Still need to do cpus, kernel, ramdisk, blockdevice, network, oh my
        self.mc = mc
    }
    /// Configures a new virtual machine
    ///   - Throws:
    ///
    func configure() throws {
        let kernel = URL(fileURLWithPath: "/Users/baude/.podman/vmlinuz")
        let ramdisk = URL(fileURLWithPath: "/Users/baude/.podman/initrd")
        let bootloader    = VZLinuxBootLoader(kernelURL: kernel)
        bootloader.initialRamdiskURL = ramdisk
        bootloader.commandLine = "console=hvc0"

        let serial = VZVirtioConsoleDeviceSerialPortConfiguration()
        serial.attachment = VZFileHandleSerialPortAttachment(fileHandleForReading: self.readPipe.fileHandleForReading, fileHandleForWriting: self.writePipe.fileHandleForWriting)



        let config = VZVirtualMachineConfiguration()
        config.bootLoader = bootloader
        config.serialPorts = [serial]
        config.memorySize = UInt64(self.mc.memory)
        config.cpuCount = 1

        do {
            try config.validate()
        } catch {
        NSLog("[!] Failure \(error)")
            throw error
        }
        self.virtualMachine =     VZVirtualMachine(configuration: config)
        self.virtualMachine.delegate = self
        print(self.virtualMachine.hashValue)

    }
    /// Starts a virtual machine
    ///   - Throws:
    ///      - `virtualMachineError.unableToStart` when container state is not stopped
    func start()  {
        print("3")
        print(self.virtualMachine.canStart)
        print(self.virtualMachine.hashValue)

        self.virtualMachine.start { result in
            switch result {
            case .success:
                print("1")
                return
            case .failure(let error):
                print("2")
                NSLog("failed: \(result)")
                NSLog("failed to start vm: \(error)")
                exit(1)
            }
        }
        print("4")
        print(self.virtualMachine.`self`())
    }
    /// Stops a virtual machine
    ///   - Throws:
    ///       - `virtualMachineError.invalidStateToStop`
    ///         when container state is not running
    func stop() throws {
        let canStop = self.virtualMachine.canRequestStop
        if canStop == false {
            throw VirtualMachineError.invalidStateToStop
        }
        try self.virtualMachine.requestStop()
    }

    func openConsole() {
        print("open console")
        consoleWindow.setContentSize(NSSize(width: 400, height: 300))
        consoleWindow.title = "Console"
        consoleWindowController.showWindow(nil)

    }

} // end of class
