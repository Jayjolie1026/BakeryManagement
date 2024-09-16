import 'package:flutter/material.dart';

// Define the Address class
class Address {
  final int addressID;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String addressType;

  Address({
    required this.addressID,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressID: json['AddressID'],
      streetAddress: json['StreetAddress'],
      city: json['City'],
      state: json['State'],
      postalCode: json['PostalCode'],
      country: json['Country'],
      addressType: json['AddressType'],
    );
  }
}

// Define the PhoneNumber class
class PhoneNumber {
  final int phoneNumberID;
  final String areaCode;
  final String phoneNumber;
  final String phoneType;

  PhoneNumber({
    required this.phoneNumberID,
    required this.areaCode,
    required this.phoneNumber,
    required this.phoneType,
  });

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
      phoneNumberID: json['PhoneNumberID'],
      areaCode: json['AreaCode'],
      phoneNumber: json['PhoneNumber'],
      phoneType: json['PhoneType'],
    );
  }
}

// Define the Email class
class Email {
  final int emailID;
  final String emailAddress;
  final String emailType;

  Email({
    required this.emailID,
    required this.emailAddress,
    required this.emailType,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      emailID: json['EmailID'],
      emailAddress: json['EmailAddress'],
      emailType: json['EmailType'],
    );
  }
}

// Define the Vendor class
class Vendor {
  final int vendorID;
  final String vendorName;
  final List<PhoneNumber> phoneNumbers;
  final List<Email> emails;
  final List<Address> addresses;

  Vendor({
    required this.vendorID,
    required this.vendorName,
    required this.phoneNumbers,
    required this.emails,
    required this.addresses,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorID: json['VendorID'] ?? 0,
      vendorName: json['VendorName'] ?? '',
      phoneNumbers: (json['PhoneNumbers'] as List<dynamic>?)
          ?.map((i) => PhoneNumber.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      emails: (json['Emails'] as List<dynamic>?)
          ?.map((i) => Email.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      addresses: (json['Addresses'] as List<dynamic>?)
          ?.map((i) => Address.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

