//
//  Contact.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import SwiftyJSON
import Contacts

struct Contact : Player {
  
  let contactId: String
  let name: String
  let firstName: String
  let lastName: String
  let insertion: String
  let email: String
  let phone: String
  let mobile: String
  let address: String
  let zip: String
  let town: String
  let country: String
  var score: Float
  let type: ContactType
  
  init(_ json: JSON) {
    contactId = json["_id"].stringValue
    name = json["name"].stringValue
    firstName = json["firstName"].stringValue
    lastName = json["lastName"].stringValue
    insertion = json["insertion"].stringValue
    email = json["email"].stringValue
    phone = json["phone"].stringValue
    mobile = json["mobile"].stringValue
    address = json["address"].stringValue
    town = json["town"].stringValue
    zip = json["zip"].stringValue
    country = json["country"].stringValue
    score = json["score"].floatValue
    
    let isParent = json["isParent"].boolValue
    let isLeader = json["isLeader"].boolValue
    
    if isParent {
      self.type = .Parent
    } else if isLeader {
      self.type = .Leader
    } else {
      self.type = .None
    }
  }
  
  func createContact() -> CNContact {
    let contact = CNMutableContact()
    contact.givenName = self.firstName
    
    if self.insertion.isEmpty {
      contact.familyName = self.lastName
    } else {
      contact.familyName = "\(self.insertion) \(self.lastName)"
    }
    
    if !self.email.isEmpty {
      contact.emailAddresses.append(CNLabeledValue(
        label: CNLabelHome, value: self.email))
    }
    if !self.phone.isEmpty {
      contact.phoneNumbers.append(CNLabeledValue(
        label: CNLabelPhoneNumberMain,
        value: CNPhoneNumber(stringValue: self.phone)))
    }
    if !self.mobile.isEmpty {
      contact.phoneNumbers.append(CNLabeledValue(
        label: CNLabelPhoneNumberMobile,
        value: CNPhoneNumber(stringValue: self.mobile)))
    }
    
    let address = CNPostalAddress()
    if !self.address.isEmpty {
      address.setValue(self.address, forKey: CNPostalAddressStreetKey)
    }
    if !self.town.isEmpty {
      address.setValue(self.town, forKey: CNPostalAddressCityKey)
    }
    if !self.zip.isEmpty {
      address.setValue(self.zip, forKey: CNPostalAddressPostalCodeKey)
    }
    if !self.country.isEmpty {
      address.setValue(self.country, forKey: CNPostalAddressCountryKey)
    }
    contact.postalAddresses.append(CNLabeledValue(label: CNLabelHome, value: address))
    return contact
  }
  
  func updateScore(operation: Operation, _ value: Float, _ callback: (Float?, NSError?) -> Void) {
    ContactService.updateScore(self, operation, value) { json, error in
      callback(json?["value"]["new"].float, error)
    }
  }
  
}

enum ContactType : CustomStringConvertible {
  
  case None
  case Parent
  case Leader
  
  var description: String {
    switch self {
    case .Parent:
      return "Ouder"
    case .Leader:
     return  "Begeleider"
    default:
      return "?"
    }
  }
  
}

class ContactService {
  
  static func byTeam(team: Team, _ page: Int = 0, _ callback: ([Contact]?, NSError?) -> Void) {
    Requests.manager.request(Router.ContactsByTeamAndPage(team, page))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var contacts = [Contact]()
          
          for item in json["items"].arrayValue {
            contacts.append(Contact(item))
          }
          
          callback(contacts, nil)
        }
    }
  }
  
  static func byUser(user: User, _ page: Int = 0, _ callback: ([Contact]?, NSError?) -> Void) {
    Requests.manager.request(Router.ContactsByUserAndPage(user, page))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var contacts = [Contact]()
          
          for item in json["items"].arrayValue {
            contacts.append(Contact(item))
          }
          
          callback(contacts, nil)
        }
      }
  }
  
  static func childrenByPage(page: Int = 0, _ callback: ([Contact]?, NSError?) -> Void) {
    Requests.manager.request(Router.ChildrenByPage(page))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var contacts = [Contact]()
          
          for item in json["items"].arrayValue {
            contacts.append(Contact(item))
          }
          
          callback(contacts, nil)
        }
    }
  }
  
  static func updateScore(contact: Contact, _ operation: Operation, _ value: Float, _ callback: (JSON?, NSError?) -> Void) {
    Requests.manager.request(Router.ContactScore(contact, operation.description, value))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          callback(json, nil)
        }
    }
  }
  
}
