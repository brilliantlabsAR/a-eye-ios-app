//
//  DeviceScreenView.swift
//  Noa
//
//  Created by Artur Burlakin on 6/29/23.
//
//  This is the view used when the device is not connected or paired. Updates are also handled
//  here.
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
}

/// State of connect button (used for pairing)
enum DeviceSheetButtonState {
    case searching
    case pair
    case connecting
    case unableToConnect
}

struct DeviceScreenView: View {
    @Binding var state: DeviceSheetState
    @Binding var pairButtonState: DeviceSheetButtonState
    @Binding var updateProgressPercent: Int
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme

    private let _onPairPressed: (() -> Void)?
    private let _onCancelPressed: (() -> Void)?

    var body: some View {
        ZStack {
            colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255).edgesIgnoringSafeArea(.all) : Color(red: 242/255, green: 242/255, blue: 247/255).edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    LogoView()

                    Spacer()
                
                    Text("Let’s set up your Frame. Take it out of the case, and bring it close.")
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
                                    pairButtonState: $pairButtonState,
                                    updateProgressPercent: $updateProgressPercent,
                                    onPairPressed: _onPairPressed,
                                    onCancelPressed: _onCancelPressed
                                )
                            )
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }

    init(deviceSheetState: Binding<DeviceSheetState>, pairButtonState: Binding<DeviceSheetButtonState>, updateProgressPercent: Binding<Int>, onPairPressed: (() -> Void)?, onCancelPressed: (() -> Void)?) {
        _state = deviceSheetState
        _pairButtonState = pairButtonState
        _updateProgressPercent = updateProgressPercent
        _onPairPressed = onPairPressed
        _onCancelPressed = onCancelPressed
    }
}

struct DeviceScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceScreenView(
            deviceSheetState: .constant(.firmwareUpdate),
            pairButtonState: .constant(.searching),
            updateProgressPercent: .constant(50),
            onPairPressed: { print("Pair pressed") },
            onCancelPressed: { print("Cancel pressed")}
        )
    }
}
