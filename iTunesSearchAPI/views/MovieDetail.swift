//
//  MovieDetail.swift
//  iTunesSearchAPI
//
//  Created by Maurice Hunter on 10/28/22.
//

import SwiftUI
import AVKit

struct MovieDetail: View {
    
    @EnvironmentObject var detailedId: SearchView.MovieIdDetails
    
    @State private var results = [Result]()
    
    var body: some View {
        ScrollView{
            ForEach(results, id: \.trackId){ item in
                VStack{
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.trackName)
                                .font(.title)
                                .fontWeight(.black)
                            Text("Directed by \(item.artistName)".uppercased())
                                .font(.caption)
                            Divider()
                            AsyncImage(url: URL(string: item.artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600"))) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200)
                                } else if phase.error != nil {
                                    Text("there was an error loading the image")
                                } else {
                                    ProgressView()
                                }
                            }
                            
                        }
                        Spacer()
                        VStack(alignment: .leading){
                            Text("Purchase Price")
                            Text("$\(doubleUnwrap(doubleOne: item.trackHdPrice, doubleTwo: item.trackPrice), specifier: "%.2f")")
                            Text("Rating: \(item.contentAdvisoryRating)")
                            Text("Runtime: \(intUnwrap(millisecond:item.trackTimeMillis)) minutes")
                        }
                    }
                    Divider()
                    HStack{
                        VStack(alignment: .leading){
                            Text("Trailer:")
                                .font(.title)
                                .fontWeight(.black)
                            VideoPlayer(player: AVPlayer(url: URL(string: item.previewUrl ?? ".mp4")!))
                                .frame(width: 300, height: 200)
                                .shadow(color: .blue ,radius: 10)
                                .padding()
                            
                            Divider()
                            Text("Description:")
                                .font(.title)
                                .fontWeight(.black)
                            Text(item.longDescription)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .task {
            await loadData()
        }
    }
    
    
    
    //https://itunes.apple.com/lookup?id=
    
    func loadData() async {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(detailedId.movieId)")
        else {
            print("URL Issue")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
            results = decodedResponse.results
        } catch {
            print(error)
        }
    }
    
    
    func doubleUnwrap(doubleOne: Double?, doubleTwo: Double?) -> Double{
        let hdPrice = doubleOne
        let sdPrice = doubleTwo
        if hdPrice != nil {
            return hdPrice ?? 0.0
        } else {
            return sdPrice ?? 0.0
        }
    }
    
    func intUnwrap(millisecond: Int?) -> Int{
        let videoMilli = millisecond
        if videoMilli != nil {
            return (videoMilli! / 60000)
        } else {
            return 0
        }
    }
}



struct MovieDetail_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetail()
    }
}
