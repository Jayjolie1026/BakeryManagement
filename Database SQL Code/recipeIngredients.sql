


ALTER TABLE dbo.tblInventory
DROP COLUMN RecipeID;
ALTER TABLE dbo.tblInventory
DROP CONSTRAINT FK__tblInvent__Recip__31B762FC;

EXEC sp_help 'dbo.tblInventory';



  CREATE TABLE tblRecipeIngredients (
    RecipeIngredientID INT IDENTITY(1,1) PRIMARY KEY,
    RecipeID INT NOT NULL,
    IngredientID INT NOT NULL,
    Quantity DECIMAL(10, 2) NOT NULL, -- Amount required for the recipe
    Measurement NVARCHAR(50), -- Optional, to store the unit of measurement
    FOREIGN KEY (RecipeID) REFERENCES tblRecipes(RecipeID),
    FOREIGN KEY (IngredientID) REFERENCES tblIngredients(IngredientID)
);
