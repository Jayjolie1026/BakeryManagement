// Define the Address class
class Address {
  int addressID;
  String streetAddress;
  String city;
  String state;
  String postalCode;
  String country;
  String addressType;

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
  int phoneNumberID;
  String areaCode;
  String phoneNumber;
  String phoneType;

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
  int emailID;
  String emailAddress;
  String emailType;

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
  int vendorID;
  String vendorName;
  List<PhoneNumber> phoneNumbers;
  List<Email> emails;
  List<Address> addresses;

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

