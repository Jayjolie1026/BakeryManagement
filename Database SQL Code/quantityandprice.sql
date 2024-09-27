SELECT  *
  FROM [dbo].[tblFinalProducts];

  ALTER TABLE dbo.tblFinalProducts
ADD Quantity INT;

ALTER TABLE dbo.tblFinalProducts
ADD Price DECIMAL(10, 2);

UPDATE dbo.tblFinalProducts
SET Quantity = 0,  -- Set default quantity
    Price = 0.00;  -- Set default price