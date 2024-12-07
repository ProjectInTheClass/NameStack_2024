//
//  LoopingScrollView.swift
//  NameStack
//
//  Created by 김세연 on 11/23/24.
//

import SwiftUI
import UIKit
import SwiftData

struct LoopingScrollView: View {
    //인자 값
    var searchText: String
    var searchTag: Dictionary<UUID,Bool>
    
    
    @Environment(\.modelContext) private var modelContext
    private let cardID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    @Query private var allCards: [Card]
    
    var cards: [Card] {
        allCards.filter { $0.id != cardID }
    }
    var body: some View {
            ScrollView( showsIndicators: false) {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width : 240, height : 250)
                    .opacity(0)
                LazyVStack{
                    ForEach(cards) { card in
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .stroke(Color.black, lineWidth: 2)
                                .shadow(radius: 10)
                                .overlay(Text("\(card.name)").bold().font(.system(size:100)))
                                //.offset( y: -200*(1-getPercentage(geo: geometry)))
                                .frame(width : 240, height : 377)
                                //.opacity(getPercentage(geo: geometry)*getPercentage(geo: geometry))
                                //.blur(radius: (1-getPercentage(geo: geometry))*10)
                                .scaleEffect(getPercentage(geo: geometry))
                                .onTapGesture{
                                    print(index)
                                }
                                .zIndex(Double(getY(geo: geometry)))
                                
                        }
                        .frame(width: 240, height: 60)
                    }
                }
                RoundedRectangle(cornerRadius: 15)
                    .frame(width : 240, height : 420)
                    .opacity(0)
            }.offset()
            .padding(.bottom, 20)
    }

        func getY(geo: GeometryProxy) -> Double {
            let midY = geo.frame(in: .global).midY
            // `midY`를 역수로 변환하여 zIndex로 반환
            return midY
        }
        func getPercentage(geo: GeometryProxy) -> Double {
            // 화면의 중앙 위치
            let maxDistance = UIScreen.main.bounds.height/2-50
            // 화면 전체 영역 기준 카드의 현재 중앙 좌표
            let currentX = geo.frame(in: .global).midY
            // 두 위치에 대한 비율 계산
            let ret = Double((currentX / maxDistance))
            if ret > 1 {return 0}
            if ret > 1.8 {return (2-ret)*(2-ret)}
            if ret > 1 {return 2-ret}
            if ret < 0.5 {return 0}
            if ret < 0.6 {return ret*ret*ret/0.36}
            
            return ret
        }
}


