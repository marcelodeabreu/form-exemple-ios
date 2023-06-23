//
//  ContentView.swift
//  Form Example
//
//  Created by Marcelo de Abreu on 09/06/23.
//

// textField.textContentType = .oneTimeCode (VERIFICAR AUTO PASS)

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    // USER AVATAR VARS
    @State private var userProfilePicture: PhotosPickerItem?
    @State private var userProfilePictureObject: UIImage?
   
    
    // USERNAME VARS
    
    @State private var username: String = ""
    @State private var isUsernameLengthValid: Bool = false
    @State private var isUsernameFormatValid: Bool = true

    // PASSWORD VARS & SECURITY
    
    @State private var passwordEntry: String = ""
    @State private var passwordReentry: String = ""
    @State private var showPassword: Bool = false
    @State private var passwordSecurityCheckPassed: Bool = false

    // PERSONAL INFO VARS
    
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var firstName: String = ""
    @State private var lastName: String = ""

    //EMAIL & SUBSCRIPTION
    
    @State private var userEmail: String = ""
    @State private var subscribeYourEmail: Bool = true
    
    var body: some View {
        Form {
            
            // USER AVATAR
            
            Section("Profile Image") {
                HStack {
                    Spacer()
                    
                    if let userProfilePictureObject {
                        Image(uiImage: userProfilePictureObject)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    }
                    
                    PhotosPicker("Select a profile image", selection: $userProfilePicture)
                        .onChange(of: userProfilePicture) { newValue in
                            Task(priority: .userInitiated) {
                                if let newValue {
                                    if let loadedImageData = try? await
                                        newValue.loadTransferable(type: Data.self),
                                     let loadedImage = UIImage(data: loadedImageData)
                                    {
                                        self.userProfilePictureObject = loadedImage
                                    }
                                }
                            }
                        }
                    
                    Spacer()
                }
            }
            
            
            // USERNAME LAYOUT
            
            Section {
                TextField("Username", text: $username)
                    .onChange(of: username) { newValue in
                        self.isUsernameLengthValid = newValue.count >= 5
                        self.isUsernameFormatValid = isValidString(newValue)
                    }
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            } header: {
                Text("Username")
            } footer: {
                VStack(alignment: .leading) {
                    Label("Min. of 5 characters.", systemImage: isUsernameLengthValid ? "checkmark" : "xmark")
                        .foregroundColor(isUsernameLengthValid ? .green : .red)
                    Label("Only alphabet, numbers or underscore.", systemImage: isUsernameFormatValid ? "checkmark" : "xmark")
                        .foregroundColor(isUsernameFormatValid ? .green : .red)
                }
            }
            
            // PASSWORD LAYOUT
            
            Section("Password") {
                HStack {
                    if showPassword {
                        TextField("Password", text: $passwordEntry)
                    } else {
                        SecureField("Password", text: $passwordEntry)
                    }
                    // Hide/Show password button
                    Button {
                        self.showPassword.toggle()
                    } label: {
                        Image(systemName: self.showPassword ? "eye" : "eye.slash")
                    }
                }
                
                SecureField("Password (Confirm)", text: $passwordReentry)
                if !passwordEntry.isEmpty,
                   !passwordReentry.isEmpty,
                   passwordEntry != passwordReentry {
                    Label("Passwords does not match", systemImage: "xmark.circle")
                        .foregroundColor(.red)
                }
                Label("Strong Passoword", systemImage: passwordSecurityCheckPassed ? "checkmark" : "xmark")
                    .foregroundColor(passwordSecurityCheckPassed ? .green : .red)
            }
            .onChange(of: passwordEntry) { newValue in
                self.passwordSecurityCheckPassed = isSecurePassword(newValue)
            }
            
            // PERSONAL INFORMATION LAYOUT
            
            Section("Personal Information") {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                
                DatePicker("Date of birth", selection: $dateOfBirth, displayedComponents: .date)
            }
            
            // EMAIL & SUBSCRIPTION LAYOUT
            
            Section("E-mail") {
                TextField("E-mail", text: $userEmail)
            }
            Toggle("Want to subscribe for news and updates?", isOn: $subscribeYourEmail)
            
            
        }
    }
    
    
     private func isSecurePassword(_ password: String) -> Bool {
   
         let lowercaseLetterRegEx = ".*[a-z]+.*"
         let uppercaseLetterRegEx = ".*[a-z]+.*"
         let digitRegEx = ".*[0-9]+.*"
         let specialCharacterRegEx = ".*[!@#$%ˆ&*]+*"
     
         let lowercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegEx)
         let uppercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegEx)
         let digitPredicate = NSPredicate(format: "SELF MATCHES %@", digitRegEx)
         let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegEx)
     
         if password.count >= 8
                && lowercaseLetterPredicate.evaluate(with: password)
                && uppercaseLetterPredicate.evaluate(with: password)
                && digitPredicate.evaluate(with: password)
                && specialCharacterPredicate.evaluate(with: password) {
             return true
     } else {
         return false
        }
     }

    
    private func isValidString(_ input: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        let inputCharacters = CharacterSet(charactersIn: input)
        
        return allowedCharacters.isSuperset(of: inputCharacters)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
