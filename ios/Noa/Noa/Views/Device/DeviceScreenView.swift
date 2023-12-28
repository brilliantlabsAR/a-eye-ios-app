//
//  DeviceScreenView.swift
//  Noa
//
//  Created by Artur Burlakin on 6/29/23.
//
//  This is the initial view on a fresh start when Moncole is unpaired and is used for device-
//  related operations: pairing, firmware update, FPGA update. Specific sheets are used for each
//  case.
//
//  Resources
//  ---------
//  - "Computed State in SwiftUI view"
//    https://yoswift.dev/swiftui/computed-state/
//

import SwiftUI

/// Device sheet types
enum DeviceSheetState {
    case hidden
    case searching
    case firmwareUpdate
    case fpgaUpdate
}

/// State of connect button (used for pairing)
enum DeviceSheetConnectButtonState {
    case searching
    case canConnect
    case connecting
}

struct DeviceScreenView: View {
    @Binding var state: DeviceSheetState
    @Binding var connectButtonState: DeviceSheetConnectButtonState
    @Binding var updateProgressPercent: Int
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme

    private let _onConnectPressed: (() -> Void)?
    private let _onCancelPressed: (() -> Void)?

    var body: some View {
        ZStack {
            colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255).edgesIgnoringSafeArea(.all) : Color(red: 242/255, green: 242/255, blue: 247/255).edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    let light = Image("BrilliantLabsLogo")
                        .resizable()
                    let dark = Image("BrilliantLabsLogo_Dark")
                        .resizable()
                    ColorModeAdaptiveImage(light: light, dark: dark)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 12)
                        .padding(.top, 80)
                    
                    Text("Noa")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, -7)
                    
                    Spacer()
                
                    Text("Let’s set up your Monocle. Take it out of the case, and bring it close.")
                        .font(.system(size: 15))
                        .frame(width: 314, height: 60)
                    
                    Spacer()

                    let privacyPolicyText = "Be sure to read our [Privacy Policy](https://brilliant.xyz/pages/privacy-policy) as well as [Terms and Conditions](https://brilliant.xyz/pages/terms-conditions) before using Noa."
                    Text(.init(privacyPolicyText))
                        .font(.system(size: 10))
                        .frame(width: 217)
                        .multilineTextAlignment(.center)
                        .accentColor(Color(red: 232/255, green: 46/255, blue: 135/255))
                        .lineSpacing(10)
                }

                VStack {
                    if state != .hidden {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white)
                            .frame(height: 350)
                            .padding(10)
                            .overlay(
                                PopupDeviceView(
                                    deviceSheetState: $state,
                                    connectButtonState: $connectButtonState,
                                    updateProgressPercent: $updateProgressPercent,
                                    onConnectPressed: _onConnectPressed,
                                    onCancelPressed: _onCancelPressed
                                )
                            )
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }

    init(deviceSheetState: Binding<DeviceSheetState>, connectButtonState: Binding<DeviceSheetConnectButtonState>, updateProgressPercent: Binding<Int>, onConnectPressed: (() -> Void)?, onCancelPressed: (() -> Void)?) {
        _state = deviceSheetState
        _connectButtonState = connectButtonState
        _updateProgressPercent = updateProgressPercent
        _onConnectPressed = onConnectPressed
        _onCancelPressed = onCancelPressed
    }
}

struct DeviceScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceScreenView(
            deviceSheetState: .constant(.firmwareUpdate),
            connectButtonState: .constant(.searching),
            updateProgressPercent: .constant(50),
            onConnectPressed: { print("Connect pressed") },
            onCancelPressed: { print("Cancel pressed")}
        )
    }
}
