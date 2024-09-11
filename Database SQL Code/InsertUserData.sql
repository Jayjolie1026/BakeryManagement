INSERT INTO tblUsers (FirstName, LastName, Username, Password)
VALUES
('John', 'Doe', 'jdoe', HASHBYTES('SHA2_256', 'password123')),
('Jane', 'Smith', 'jsmith', HASHBYTES('SHA2_256', 'mysecurepass')),
('Bob', 'Johnson', 'bjohnson', HASHBYTES('SHA2_256', 'welcome2024')),
('Alice', 'Williams', 'awilliams', HASHBYTES('SHA2_256', 'alicepassword')),
('Charlie', 'Brown', 'cbrown', HASHBYTES('SHA2_256', 'chocolate!'));
