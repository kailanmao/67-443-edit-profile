//
//  MyTripsView.swift
//  Travel
//
//  Created by Cindy Jiang on 2024/10/29.
//

import SwiftUI

struct MyTripsView: View {
//	@EnvironmentObject var aliceVM: MockUser
  @ObservedObject var tripRepository: TripRepository
  @ObservedObject var locationRepository: LocationRepository
	@State private var showNewTripView = false
  @State var forceUpdate = false
	
	// search stuff
	@State var searchText: String = ""
	@State var displayedTrips: [Trip] = [Trip]()
	
	let currUser: User
	
	var body: some View {
		let binding = Binding<String>(get: {
			self.searchText
		}, set: {
			self.searchText = $0
			self.tripRepository.search(searchText: self.searchText)
			self.displayTrips()
		})
		
		NavigationView {
			VStack {
				HStack {
					Text("My Trips")
						.font(.largeTitle)
						.fontWeight(.bold)
						.padding(.top, 15)
						.padding(.leading, 20)
					Spacer()
					Button(action: {
						showNewTripView = true
					}) {
						Image(systemName: "plus.circle")
							.font(.largeTitle)
							.padding(.trailing, 20)
							.padding(.top, 15)
					}
				}
				
				HStack {
					TextField("Search trips...", text: binding)
						.padding(.leading, 10) // Extra padding for text
						.padding(.vertical, 15)
					
					
					if !searchText.isEmpty {
						Button(action: {
							searchText = ""
							displayTrips() // Update displayedLocations after clearing
						}) {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(.gray)
						}
						.padding(.trailing, 10)
					}
				}
				.background(Color(.systemGray5))
				.cornerRadius(15)
				.padding(.horizontal, 20)
				.padding(.bottom, 10)
				
				if !searchText.isEmpty {
					ScrollView {
            ForEach(tripRepository.filteredTrips.filter { currUser.Trips.contains($0.id) }.sorted {
							($0.startDateAsDate ?? .distantPast) > ($1.startDateAsDate ?? .distantPast)
		 }) { trip in
							NavigationLink(destination: TripDetailsView(trip: trip, tripRepository: tripRepository, locationRepository: locationRepository, currUser: currUser)
														 //                .environmentObject(aliceVM)
							) {
                TripCardView(trip: trip, tripRepository: tripRepository, forceUpdate: forceUpdate)
									.padding(.bottom, 10)
									.padding(.top, 10)
							}
						}
					}
					.padding(.horizontal)
				} else {
					ScrollView {
						ForEach(tripRepository.trips.filter { currUser.Trips.contains($0.id) }.sorted {
							($0.startDateAsDate ?? .distantPast) > ($1.startDateAsDate ?? .distantPast)
		 }) { trip in
							NavigationLink(destination: TripDetailsView(trip: trip, tripRepository: tripRepository, locationRepository: locationRepository, currUser: currUser)
														 //                .environmentObject(aliceVM)
							) {
                TripCardView(trip: trip, tripRepository: tripRepository, forceUpdate: forceUpdate)
									.padding(.bottom, 10)
									.padding(.top, 10)
							}
						}
					}
				}
			}
			.navigationBarHidden(true)
			.sheet(isPresented: $showNewTripView) {
				NewTripView(isPresented: $showNewTripView, tripRepository: tripRepository, currUser: currUser)
					.presentationDetents([.fraction(0.97)])
					.presentationDragIndicator(.visible)
//					.environmentObject(aliceVM)
			}
			.onAppear {
				tripRepository.get()
				self.displayTrips() // Initialize displayedTrips with all trips
			}
		}
	}
	
	private func displayTrips() {
		if searchText == "" {
			displayedTrips = tripRepository.trips
			tripRepository.filteredTrips = tripRepository.trips
		} else {
			displayedTrips = tripRepository.filteredTrips
		}
	}
}

//struct MyTripsView_Previews: PreviewProvider {
//  static var previews: some View {
//		MyTripsView()
//  }
//}
