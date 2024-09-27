

INSERT INTO tblAddressTypes ([Description])
VALUES ('Home'), ('Work'), ('Billing'), ('Shipping');



  INSERT INTO tblEmailTypes (Description, Active)
VALUES 
('Personal', 1),  -- Active personal email address
('Work', 1),      -- Active work email address
('Billing', 1),   -- Email for billing purposes
('Support', 1),   -- Email for support communication
('Other', 1);     -- Any other type of email address 

  INSERT INTO tblPhoneTypes (Description, Active)
VALUES 
('Mobile', 1),  -- Active mobile phone number
('Home', 1),    -- Active home phone number
('Work', 1),    -- Active work phone number
('Fax', 1),     -- Active fax number
('Other', 1);   -- Any other type of phone number
