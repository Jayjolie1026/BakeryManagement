CREATE TABLE tblJobs (
    JobID INT PRIMARY KEY IDENTITY(1,1),  -- JobID as an auto-incrementing primary key
    Description VARCHAR(255) NOT NULL      -- Description of the job
);


ALTER TABLE tblUsers
ADD JobID INT;

ALTER TABLE tblUsers
ADD CONSTRAINT FK_Users_Jobs FOREIGN KEY (JobID) REFERENCES tblJobs(JobID);


INSERT INTO tblJobs (Description) VALUES 
('Owner'),
('Manager'),
('Employee');


CREATE TABLE tblTasks (
    TaskID INT PRIMARY KEY IDENTITY(1,1),
    Description VARCHAR(100) NOT NULL,
    CreateDate DATE ,
    DueDate DATE ,
    AssignedBy UNIQUEIDENTIFIER,
    FOREIGN KEY (AssignedBy) REFERENCES tblUsers(EmployeeID)  
);


select * from tblRecipes;