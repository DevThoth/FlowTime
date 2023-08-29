//
//  MenuBar.swift
//  FlowTime
//
//  Created by Leonardo Migliorelli on 21/06/23.
//

import SwiftUI

struct MenuBar: Scene {
	@Environment(\.openWindow) private var openWindow
	@StateObject private var clockModel: ClockModel = ClockModel.shared
	@StateObject private var relaxModel: RelaxModel = RelaxModel(ClockModel.shared.relaxingTime)
	
	@AppStorage("settings.showtimer") private var showTimer = true
	@AppStorage("actual") var actualId = 0
	@AppStorage("profilesString") var profiles = [Profile]()
	
	private var others: [Profile] {
		StorageManager.profile.filter { $0 != StorageManager.actualProfile }
	}
	
	private var actual: Profile {
		if profiles.count == 0 {
			profiles.append(Profile(title: "Default"))
		}
		
		if profiles.count <= actualId {
			actualId = 0
		}
		
		return profiles[actualId]
	}
	
	var body: some Scene {
		MenuBarExtra(
			content: {
				if clockModel.relaxingTime == 0 {
					if clockModel.isPaused {
						Button(action: clockModel.start) {
							Image(systemName: "play.fill")
							Text("Start")
						}
					} else {
						Button(action: clockModel.endSession) {
							Image(systemName: "cup.and.saucer.fill")
							Text("Relax for \(clockModel.relaxDuration.minuteSecond)")
						}
					}
					
					Button(action: clockModel.reset) {
						Image(systemName: "trash.fill")
						Text("Cancel")
					}
					
					Divider()
				}
				
				if profiles.count == 1 {
					Button(actual.title) {}
				} else {
					Menu("Profile \(actual.title)") {
						ForEach(others, id: \.self) { p in
							Button(p.title) {
								StorageManager.actualProfile = p
							}
						}
					}
				}
				
				Button(action: {
					NSApplication.shared.activate(ignoringOtherApps: true)
					openWindow(id: "EditProfile")
				}, label: {
					Image(systemName: "pencil")
					Text("Edit Profiles")
				})
				
				Text("Total ~ \(clockModel.actualTotal.minuteSecond)")
					.foregroundColor(.black)
				Text("Record ~ \(clockModel.actualRecord.minuteSecond)")
				
				Button(action: {StorageManager.actualProfile.reset()}) {
					Image(systemName: "gobackward")
					Text("Reset")
				}

				Button("Open View"){
					NSApplication.shared.activate(ignoringOtherApps: true)
					openWindow(id: "MainScreen")
				}.keyboardShortcut("n")
				
				Divider()
				
				
				Button(action: {
					NSApplication.shared.activate(ignoringOtherApps: true)
					openWindow(id: "Settings")
				}, label: {
					Text("Preferences...")
				})
				.keyboardShortcut(",")
			
				Button("Quit"){
					NSApplication.shared.terminate(nil)
				}.keyboardShortcut("q")
					.onAppear { clockModel.relaxingTime = 0 }
			}, label: {
				if clockModel.relaxingTime == 0 {
					Image(systemName: "timer", withHierarchicalColor: actual.color.nsColor)
					
					Text(clockModel.duration.minuteSecond)
						.hidden(!showTimer)
						.hidden(clockModel.isPaused)
				} else {
					Image(systemName: "cup.and.saucer.fill", withHierarchicalColor: actual.color.nsColor)
					Text(relaxModel.duration.minuteSecond)
						.onAppear(perform: relaxModel.start)
				}
			}
		)
	}
}

