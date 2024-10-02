select * from tblVendors;
select * from tblVendorAddresses;
select * from tblVendorEmails;
select * from tblVendorPhoneNumbers;

select * from tblIngredients;
select * from tblVendors;


INSERT INTO tblVendors (VendorName)
VALUES('Flour Power');

INSERT INTO tblVendors (VendorName)
VALUES('Dairy Delights');

INSERT INTO tblVendors (VendorName)
VALUES('Whisk & Spice');

INSERT INTO tblVendors (VendorName)
VALUES('Choco Loco');

INSERT INTO tblVendors (VendorName)
VALUES('Freshly Picked');

INSERT INTO tblVendors (VendorName)
VALUES('Nutty Nibbles');



DELETE FROM tblVendorPhoneNumbers
WHERE VendorID Between 19 and 28;


INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('flourpower@gmal.com', 48, 1, 1);

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('111 Elf St', 'Cookeville', 'TN', '38501', 'US', 1,48, 1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('615', '1234567', 1, 1, 48);

INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('DairyDEElights@gmail.com', 49, 1, 1);

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('555 Big St', 'Algood', 'TN', '38505', 'US', 1,49,1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('931', '7891556', 1, 1, 49);

INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('Whisk-IT@yahoo.com',50,1,1 );

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('567 Vanview Dr', 'Sparta', 'TN', '38505', 'US', 1, 50, 1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('931', '7678903', 1, 1, 50);

INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('chocoloco@gmail.com', 51, 1, 1);

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('451 Madduc Ave', 'Cookeville', 'TN', '38505', 'US', 1 , 51, 1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('615', '2341111', 1,1, 51);

INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('freshlypicked@gmail.com', 52, 1, 1);

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('678 High Blvd', 'Algood', 'TN', '38501', 'US', 1, 52, 1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('615', '9312222',1,1, 52 );

INSERT INTO tblVendorEmails ( EmailAddress, VendorID, TypeID, Valid)
VALUES ('NuttyNibbles@yahoo.com', 53, 1, 1);

INSERT into tblVendorAddresses (StreetAddress,City,[State],PostalCode,Country,AddressTypeID,VendorID,Active)
VALUES ('654 Yahoo Dr', 'Sparta', 'TN', '38501', 'US', 1, 53, 1);

INSERT INTO tblVendorPhoneNumbers (AreaCode,Number,TypeID,Valid,VendorID)
VALUES ('931', '5555555', 1, 1, 53);

DELETE from tblVendorAddresses 
where VendorID BETWEEN 18 and 45; 
DELETE from tblVendorAddresses 
where VendorID = 49; 

DELETE from tblVendorEmails 
where VendorID between 18 and 45;

delete from tblVendorPhoneNumbers 
where VendorID Between 18 and 49;

Update tblIngredients 
set VendorID = 48
where VendorID = 19;

Update tblIngredients 
set VendorID = 48
where VendorID = 2;

Update tblIngredients 
set VendorID = 48
where VendorID = 5;


Update tblIngredients 
set VendorID = 48
where VendorID = 19;


Update tblIngredients 
set VendorID = 48
where IngredientID = 25;


UPDATE tblIngredients
SET Measurement = 'grams'
where IngredientID BETWEEN 16 and 17;


Update tblIngredients 
set VendorID = 49
where VendorID = 3;
Update tblIngredients 
set VendorID = 49
where VendorID = 4;

Update tblIngredients 
set VendorID = 49
where IngredientID = 80;


Update tblIngredients 
set VendorID = 50
where IngredientID = 27;

Update tblIngredients 
set VendorID = 50
where IngredientID = 28;
Update tblIngredients 
set VendorID = 50
where IngredientID = 29;
Update tblIngredients 
set VendorID = 50
where IngredientID = 30;

Update tblIngredients 
set VendorID = 48
where IngredientID = 31;


Update tblIngredients 
set VendorID = 48
where IngredientID = 35;

Update tblIngredients 
set VendorID = 48
where IngredientID = 34;


Update tblIngredients 
set VendorID = 51
where IngredientID = 26;
Update tblIngredients 
set VendorID = 51
where IngredientID = 37;
Update tblIngredients 
set VendorID = 51
where IngredientID = 38;

Update tblIngredients 
set VendorID = 52
where IngredientID = 39;
Update tblIngredients 
set VendorID = 52
where IngredientID = 73;
Update tblIngredients 
set VendorID = 52
where IngredientID = 81;
Update tblIngredients 
set VendorID = 52
where IngredientID = 32;
Update tblIngredients 
set VendorID = 52
where IngredientID = 33;
Update tblIngredients 
set VendorID = 52
where IngredientID = 76;

Update tblIngredients 
set VendorID = 53
where IngredientID = 75;