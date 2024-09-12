-- Creating Users Table
CREATE TABLE tblUsers (
    EmployeeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Username VARCHAR(100) UNIQUE,
    Password VARCHAR(255) -- Ensure passwords are hashed securely
);

-- Creating Email Types Table
CREATE TABLE tblEmailTypes (
    TypeID INT PRIMARY KEY IDENTITY,
    Description VARCHAR(100),
    Active BIT
);

-- Creating Emails Table
CREATE TABLE tblEmails (
    EmailID INT PRIMARY KEY IDENTITY,
    EmailAddress VARCHAR(255),
    EmployeeID UNIQUEIDENTIFIER,
    TypeID INT,
    Valid BIT,
    FOREIGN KEY (EmployeeID) REFERENCES tblUsers(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (TypeID) REFERENCES tblEmailTypes(TypeID)
);

-- Creating Phone Types Table
CREATE TABLE tblPhoneTypes (
    TypeID INT PRIMARY KEY IDENTITY,
    Description VARCHAR(100),
    Active BIT
);

-- Creating Phone Numbers Table
CREATE TABLE tblPhoneNumbers (
    PhoneNumberID INT PRIMARY KEY IDENTITY,
    AreaCode VARCHAR(10),
    Number VARCHAR(20),
    TypeID INT,
    Valid BIT,
    EmployeeID UNIQUEIDENTIFIER,
    FOREIGN KEY (EmployeeID) REFERENCES tblUsers(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (TypeID) REFERENCES tblPhoneTypes(TypeID)
);

-- Creating Address Types Table
CREATE TABLE tblAddressTypes (
    AddressTypeID INT PRIMARY KEY IDENTITY,
    Description VARCHAR(100),  -- Description of the address type
    Active BIT                 -- Indicates if this address type is active
);

-- Creating Addresses Table
CREATE TABLE tblAddresses (
    AddressID INT PRIMARY KEY IDENTITY,
    StreetAddress VARCHAR(255),   -- Street address (e.g., 123 Main St)
    City VARCHAR(100),            -- City name
    State VARCHAR(100),           -- State or region
    PostalCode VARCHAR(20),       -- Zip or postal code
    Country VARCHAR(100),         -- Country name
    AddressTypeID INT,            -- Foreign key to address type (e.g., billing, shipping)
    EmployeeID UNIQUEIDENTIFIER,
    Active BIT,                   -- Indicates if the address is currently active
    FOREIGN KEY (AddressTypeID) REFERENCES tblAddressTypes(AddressTypeID),
    FOREIGN KEY (EmployeeID) REFERENCES tblUsers(EmployeeID) ON DELETE CASCADE
);

-- Creating Vendors Table
CREATE TABLE tblVendors (
    VendorID INT PRIMARY KEY IDENTITY,
    VendorName VARCHAR(255)
);

-- Creating Vendor Addresses Table
CREATE TABLE tblVendorAddresses (
    AddressID INT PRIMARY KEY IDENTITY,
    StreetAddress VARCHAR(255),   -- Street address (e.g., 123 Main St)
    City VARCHAR(100),            -- City name
    State VARCHAR(100),           -- State or region
    PostalCode VARCHAR(20),       -- Zip or postal code
    Country VARCHAR(100),         -- Country name
    AddressTypeID INT,            -- Foreign key to address type (e.g., billing, shipping)
    VendorID INT,
    Active BIT,                   -- Indicates if the address is currently active
    FOREIGN KEY (AddressTypeID) REFERENCES tblAddressTypes(AddressTypeID),
    FOREIGN KEY (VendorID) REFERENCES tblVendors(VendorID) ON DELETE CASCADE
);

-- Creating Vendor Phone Numbers Table
CREATE TABLE tblVendorPhoneNumbers (
    PhoneNumberID INT PRIMARY KEY IDENTITY,
    AreaCode VARCHAR(10),
    Number VARCHAR(20),
    TypeID INT,
    Valid BIT,
    VendorID INT,
    FOREIGN KEY (VendorID) REFERENCES tblVendors(VendorID) ON DELETE CASCADE,
    FOREIGN KEY (TypeID) REFERENCES tblPhoneTypes(TypeID)
);

-- Creating Vendor Email Table
CREATE TABLE tblVendorEmails (
    EmailID INT PRIMARY KEY IDENTITY,
    EmailAddress VARCHAR(255),
    VendorID INT,
    TypeID INT,
    Valid BIT,
    FOREIGN KEY (VendorID) REFERENCES tblVendors(VendorID) ON DELETE CASCADE,
    FOREIGN KEY (TypeID) REFERENCES tblEmailTypes(TypeID)
);

-- Creating Ingredients Table
CREATE TABLE tblIngredients (
    IngredientID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Description VARCHAR(255),
    Category VARCHAR(100),
    Measurement VARCHAR(50),
    MaxAmount DECIMAL(10, 2),
    ReorderAmount DECIMAL(10, 2),
    MinAmount DECIMAL(10, 2),
    VendorID INT,  -- Reference VendorID instead of VendorName
    FOREIGN KEY (VendorID) REFERENCES tblVendors(VendorID) 
);

-- Creating Employee Attendance Table
CREATE TABLE tblEmployeeAttendance(
    AttendanceID INT PRIMARY KEY IDENTITY,
    EmployeeID UNIQUEIDENTIFIER,
    ClockInTime TIME DEFAULT CAST(GETDATE() AS TIME), 
    ClockOutTime TIME, 
    Date DATE NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES tblUsers(EmployeeID)
);

-- Creating Final Products Table
CREATE TABLE tblFinalProducts (
    ProductID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(255),
    Description VARCHAR(255),
    MaxAmount DECIMAL(10, 2),
    RemakeAmount DECIMAL(10, 2),
    MinAmount DECIMAL(10, 2)
);

-- Creating Recipes Table
CREATE TABLE tblRecipes (
    RecipeID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Steps VARCHAR(MAX),
    ProductID INT,
    FOREIGN KEY (ProductID) REFERENCES tblFinalProducts(ProductID)
);

-- Creating Inventory Table
CREATE TABLE tblInventory (
    EntryID INT PRIMARY KEY IDENTITY,
    Quantity DECIMAL(10, 2),
    Notes VARCHAR(255),
    Cost DECIMAL(10, 2),
    CreateDateTime DATETIME,
    ExpireDateTime DATETIME,
    RecipeID INT,
    FOREIGN KEY (RecipeID) REFERENCES tblRecipes(RecipeID) 
);

-- Creating Sessions Table
CREATE TABLE tblSessions (
    SessionID INT PRIMARY KEY IDENTITY,
    EmployeeID UNIQUEIDENTIFIER,
    CreateDateTime DATETIME,
    LastActivityDateTime DATETIME,
    FOREIGN KEY (EmployeeID) REFERENCES tblUsers(EmployeeID)
);
