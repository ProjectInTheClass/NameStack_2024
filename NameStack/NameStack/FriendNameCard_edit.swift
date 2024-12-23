//
//  MyNameCardView.swift
//  1107
//
//  Created by 김세연 on 11/7/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import SwiftData


struct FriendNameCard_edit: View {
    var namecardID: UUID
    var isNewCard: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allCards: [Card]
    private let defaultCardID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    var thisCard: [Card] {
        allCards.filter { $0.id == namecardID }
    }
    //var thisCard: Card
        
    let paletteColors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .brown, .gray]

    @State private var name: String = ""
    @State private var organization: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var school: String = ""
    @State private var url: String = ""
    @State private var memo: String = ""

    
   // @State private var path = NavigationPath()
    
    @Binding var path: NavigationPath
    @Binding var isTabBarVisible: Bool
    @Binding var selectedTab: Int
    
    @State private var showSaveAlert = false
    
    private let context = CIContext()
    private let qrFilter = CIFilter.qrCodeGenerator()
    private let colorFilter = CIFilter.falseColor()
    

    
    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    if isNewCard && !thisCard.isEmpty {
                            if let cardToDelete = thisCard.first {
                                modelContext.delete(cardToDelete) // 현재 편집 중인 새 카드를 삭제
                            }
                        }
                    path.removeLast()
                }) {
                    Image("Arrow")
                        .padding(
                            EdgeInsets(top: 7.50, leading: 3.75, bottom: 7.50, trailing: 3.75)
                        )
                } .frame(width: 30, height: 30)
                .position(x: 50, y: 20);
                
                Text("NameStack")
                    .font(Font.custom("Jura", size: 30).weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 175, height: 35)
                    .position(x: UIScreen.main.bounds.width / 2, y: 20);
                
                Button(action: {
                    if let cardToDelete = thisCard.first {
                        modelContext.delete(cardToDelete) // 현재 편집 중인 새 카드를 삭제
                    }
                    withAnimation{path.removeLast()}
                }) {
                    Image("delete")
                        .padding(
                            EdgeInsets(top: 7.50, leading: 3.75, bottom: 7.50, trailing: 3.75)
                        )
                }
                .frame(width: 30, height: 30)
                .position(x: UIScreen.main.bounds.width-50, y: 20);
                
                VStack(spacing: 20) {
                    
                    Spacer()
                        .frame(height:70)
                    
                    ScrollView{
                        ZStack{
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 237, height: 377)
                                .background(.white)
                                .cornerRadius(15.43)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15.43)
                                        .inset(by: 0.5)
                                        .stroke(Constants.GraysBlack, lineWidth: 1)
                                )
                            HStack{
                                Spacer()
                                    .frame(width:10)
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(name.isEmpty ? "Your Name" : name)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    if !thisCard.isEmpty {
                                        HStack {
                                            ForEach(thisCard[0].tags) { tag in
                                                Circle()
                                                    .fill(paletteColors[tag.colorIndex]).opacity(0.8) // 태그 색상
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding(.top, 2)
                                    }

                                    Spacer()
                                        .frame(height:10)
                                    
                                    Text(school.isEmpty ? "Your School" : school)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Text(phoneNumber.isEmpty ? "Your Phone Number" : phoneNumber)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    
                                    Text(email.isEmpty ? "Your Email" : email)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                        .frame(height:100)

                                }
                                .padding()
                                Spacer()
                            }
                            //      .padding(.trailing, 40)
                            
                            Text(organization.isEmpty ? "Your Organization" : organization)
                                .font(.footnote)
                                .foregroundColor(.black)
                                .padding(.top,300)
                        }.frame(width:200, height:377)
                            .padding(.bottom,15)
                        
                        VStack(spacing: 15) {
                            Button(action:{
                                if(isNewCard){
                                    saveData()
                                    loadData()
                                }
                                withAnimation{ path.append(MainDestination.editTag(namecardID))}
                            }){
                                ZStack{
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 89, height: 25)
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .inset(by: 0.5)
                                                .stroke(.white, lineWidth: 1)
                                        )
                                    HStack{
                                        
                                        Image("Tag")
                                            .frame(width: 14, height: 14)
                                        
                                        Text("태그 편집")
                                            .font(Font.custom("Roboto", size: 11))
                                            .kerning(0.25)
                                            .foregroundColor(.white)
                                        
                                        
                                    }
                                    
                                }.padding(.bottom, 10)
                            }
                            CustomTextField(title: "이름", text: $name)
                            CustomTextField(title: "소속", text: $organization)
                            CustomTextField(title: "전화번호", text: $phoneNumber, keyboardType: .phonePad)
                            CustomTextField(title: "이메일", text: $email, keyboardType: .emailAddress)
                            CustomTextField(title: "학교", text: $school)
                            CustomTextField(title: "URL", text: $url, keyboardType: .URL)
                            CustomTextField(title: "메모", text: $memo, isMultiline: true)
                        }
                        .padding(.horizontal)
                        
                        
                        // Save Button
                        Button(action: {
                            showSaveAlert=true
                            saveData()
                            path.append(MainDestination.friendCards)
                                
                            
                            // Action for save button
                        }) {
                            Text("저장")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                }
            }   .onAppear{
                loadData()
                isTabBarVisible = false
                } //
                .navigationBarBackButtonHidden(true)
                .onTapGesture {
                    dismissKeyboard()// 키보드 밖 공간 눌렀을 때 키보드 닫기
                }
                .alert("저장되었습니다", isPresented: $showSaveAlert) { // Alert 표시
                    Button("확인", role: .cancel) {}
                }
            
            /*
                .navigationDestination(for: UIImage.self) { qrImage in
                    QRCode(qrImage: qrImage, path:$path) // QRCodeView로 QR 코드 이미지 전달
                }*/
        
        
    }
    private func dismissKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
    
    // QR 코드에 포함될 데이터 문자열
    private func qrDataString() -> String {
        
        """
        Name: \(name)
        Organization: \(organization)
        Phone Number: \(phoneNumber)
        Email: \(email)
        School: \(school)
        URL: \(url)
        Memo: \(memo)
        """
    }

    // QR 코드 생성 함수
   /* private func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // 10배 확대하여 선명한 QR 코드 생성
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            
            if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
*/
    private func generateQRCode(from string: String) -> UIImage? {
        qrFilter.message = Data(string.utf8)
        
        if let qrOutputImage = qrFilter.outputImage {
            // 색상 필터 설정: 포어그라운드를 흰색으로, 배경을 검정색으로 설정
            colorFilter.inputImage = qrOutputImage
            colorFilter.color0 = CIColor.white // QR 코드 색상
            colorFilter.color1 = CIColor.black // 배경색
            
            // 이미지 렌더링 및 반환
            if let coloredQRImage = colorFilter.outputImage,
               let cgImage = context.createCGImage(coloredQRImage.transformed(by: CGAffineTransform(scaleX: 1, y: 1)), from: coloredQRImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    // 데이터 저장 함수
    private func saveData() {
        if(!thisCard.isEmpty){
            thisCard[0].name = name
            thisCard[0].organization = organization
            thisCard[0].phoneNumber = phoneNumber
            thisCard[0].mail = email
            thisCard[0].school = school
            thisCard[0].URL = url
            thisCard[0].memo = memo
        }
        else{
            let newCard: Card = Card(id: namecardID, name: name, phoneNumber: phoneNumber, mail: email, organization: organization, school: school, URL: url, memo: memo)
            do {
                modelContext.insert(newCard)
            try modelContext.save()
            } catch {
              print("error")
            }
        }
        print("Data saved.")
    }

    // 데이터 로드 함수
    private func loadData() {
        if(!thisCard.isEmpty){
            name = thisCard[0].name
            organization = thisCard[0].organization
            phoneNumber = thisCard[0].phoneNumber
            email = thisCard[0].mail
            school = thisCard[0].school
            url = thisCard[0].URL
            memo = thisCard[0].memo
        }
        //print("Data loaded.")
    }
    
}

/*
struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false

    var body: some View {
        if isMultiline {
            
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black) // 검정색 배경
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                    )
                
                VStack{
                    HStack{
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.gray) // 위에 작은 타이틀
                            .padding(.leading,15)
                        Spacer()
                    }.padding(.top,10)
                    TextEditor(text: $text)
                        .frame(height: 100)
                        .padding(.horizontal, 10)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                }
            }
        } else {
            ZStack{
                RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1)
                VStack{
                    HStack{
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading,15)
                        Spacer()
                    }.padding(.top,10)
                    TextField(title, text: $text)
                        .keyboardType(keyboardType)
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        .padding(.bottom,10)
                    
                        .background(Color.black.opacity(0.1))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                }
                    
            }
        }
    }
}
 */
/*
// QR 코드 표시 뷰
struct QRCodeView: View {
var qrImage: UIImage?
    @Binding var path: NavigationPath
    
var body: some View {
    ZStack{
        Color.black.ignoresSafeArea(.all)
        VStack() {
            HStack {
                Button(action: {
                    path.removeLast() // NavigationStack에서 뒤로 가기
                }) {
                    Image("Arrow")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                Spacer()
                
                Image("NameStack")
                    .resizable()
                    .frame(width: 180, height: 30)
                    .padding()
                   
                
                Spacer()
                
            }
        
            Spacer()
                .frame(height:60)
            
            Text("내 명함 공유하기")
              .font(
                Font.custom("Urbanist", size: 23)
                  .weight(.medium)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(.white)
              .frame(width: 218, height: 24, alignment: .center)
              .padding()
            
            if let qrImage = qrImage {
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("QR 코드 생성 실패")
                    .foregroundColor(.red)
            }
            
            Spacer()
                .frame(height:30)
            
            Button(action: {
                // 새로고침 기능이나 원하는 동작 추가
                print("QR Code 새로고침 버튼 눌림")
            }) {
                HStack {
                    
                    Text("QR Code 새로고침")
                        .font(
                            Font.custom("Montserrat", size: 14)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 218, height: 24, alignment: .center)
                }
                .frame(width: 179, height: 33, alignment: .center)
                .background(Constants.GraysBlack)
                .cornerRadius(30)
                .shadow(color: Color(red: 0.18, green: 0.18, blue: 0.18).opacity(0.15), radius: 7.5, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .inset(by: 0.5)
                        .stroke(.white, lineWidth: 1)
                )
            }
            Spacer()
            
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
}
*/


#Preview {
    ContentView()
}

