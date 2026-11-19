-- QueueFlow Incremental Capstone
-- Sprint 1: Database Creation

IF DB_ID('QueueFlowDB') IS NULL
BEGIN
    CREATE DATABASE QueueFlowDB;
END;
GO

USE QueueFlowDB;
GO

SELECT DB_NAME() AS CurrentDatabase;
GO


USE QueueFlowDB;
GO

-- 1. AGENT TABLE
CREATE TABLE Agent (
    AgentID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Offline',
    CONSTRAINT CK_Agent_Status
        CHECK (Status IN ('Available', 'Busy', 'Offline', 'Paused'))
);
GO

-- 2. SKILL TABLE
CREATE TABLE Skill (
    SkillID INT IDENTITY(1,1) PRIMARY KEY,
    SkillName VARCHAR(100) NOT NULL UNIQUE
);
GO

-- 3. AGENT SKILL TABLE
CREATE TABLE AgentSkill (
    AgentSkillID INT IDENTITY(1,1) PRIMARY KEY,
    AgentID INT NOT NULL,
    SkillID INT NOT NULL,
    ProficiencyLevel INT NOT NULL,
    CONSTRAINT FK_AgentSkill_Agent
        FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT FK_AgentSkill_Skill
        FOREIGN KEY (SkillID) REFERENCES Skill(SkillID),
    CONSTRAINT UQ_AgentSkill UNIQUE (AgentID, SkillID),
    CONSTRAINT CK_AgentSkill_Proficiency
        CHECK (ProficiencyLevel BETWEEN 1 AND 5)
);
GO

-- 4. CUSTOMER TABLE
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Tier VARCHAR(20) NOT NULL DEFAULT 'Standard',
    CONSTRAINT CK_Customer_Tier
        CHECK (Tier IN ('Standard', 'Premium', 'VIP'))
);
GO

-- 5. REQUEST TABLE
CREATE TABLE Request (
    RequestID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    RequiredSkillID INT NOT NULL,
    Priority INT NOT NULL DEFAULT 0,
    Channel VARCHAR(10) NOT NULL,
    ReceivedAt DATETIME2(6) NOT NULL DEFAULT SYSUTCDATETIME(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Queued',

    CONSTRAINT FK_Request_Customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Request_Skill
        FOREIGN KEY (RequiredSkillID) REFERENCES Skill(SkillID),
    CONSTRAINT CK_Request_Priority
        CHECK (Priority BETWEEN 0 AND 5),
    CONSTRAINT CK_Request_Channel
        CHECK (Channel IN ('Call', 'Chat')),
    CONSTRAINT CK_Request_Status
        CHECK (Status IN ('Queued', 'Assigned', 'Completed', 'Escalated'))
);
GO

CREATE INDEX IX_Request_Skill_Status
ON Request (RequiredSkillID, Status);
GO

-- 6. ROUTING DECISION TABLE
CREATE TABLE RoutingDecision (
    DecisionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RequestID BIGINT NOT NULL,
    AgentID INT NOT NULL,
    RoutedAt DATETIME2(6) NOT NULL DEFAULT SYSUTCDATETIME(),
    WaitSeconds INT NOT NULL,

    CONSTRAINT FK_RoutingDecision_Request
        FOREIGN KEY (RequestID) REFERENCES Request(RequestID),
    CONSTRAINT FK_RoutingDecision_Agent
        FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT CK_RoutingDecision_Wait
        CHECK (WaitSeconds >= 0)
);
GO

-- VERIFY TABLES
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

USE QueueFlowDB;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


USE QueueFlowDB;
GO

-- 1. INSERT 10 AGENTS
INSERT INTO Agent (FirstName, LastName, Status)
VALUES
('Arun', 'Kumar', 'Available'),
('Priya', 'Sharma', 'Available'),
('Karthik', 'Rajan', 'Busy'),
('Divya', 'Mohan', 'Available'),
('Rahul', 'Das', 'Offline'),
('Sneha', 'Ravi', 'Available'),
('Vikram', 'Singh', 'Paused'),
('Meena', 'Devi', 'Available'),
('Ajay', 'Kumar', 'Busy'),
('Anitha', 'Raj', 'Available');
GO

-- 2. INSERT 10 SKILLS
INSERT INTO Skill (SkillName)
VALUES
('Technical Support'),
('Billing'),
('Sales'),
('Customer Service'),
('Account Management'),
('Product Support'),
('Network Support'),
('Refunds'),
('Complaints'),
('General Enquiry');
GO

-- 3. INSERT 10 CUSTOMERS
INSERT INTO Customer (FirstName, LastName, Tier)
VALUES
('Ramesh', 'Kumar', 'Standard'),
('Lakshmi', 'Devi', 'Premium'),
('Suresh', 'Raj', 'VIP'),
('Kavya', 'Shan', 'Standard'),
('Manoj', 'Das', 'Premium'),
('Nithya', 'Ravi', 'VIP'),
('Bala', 'Murugan', 'Standard'),
('Pooja', 'Singh', 'Premium'),
('Gokul', 'Krishnan', 'Standard'),
('Harini', 'Mohan', 'VIP');
GO

-- VERIFY
SELECT * FROM Agent;
SELECT * FROM Skill;
SELECT * FROM Customer;
GO



USE QueueFlowDB;
GO

-- 4. INSERT AGENT SKILLS
INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
VALUES
(1, 1, 5),
(1, 7, 4),
(2, 2, 5),
(2, 8, 4),
(3, 3, 4),
(3, 4, 3),
(4, 1, 4),
(4, 6, 5),
(5, 7, 3),
(6, 4, 5),
(6, 9, 4),
(7, 5, 3),
(8, 8, 5),
(8, 10, 4),
(9, 3, 5),
(10, 4, 4),
(10, 10, 5);
GO

-- 5. INSERT 200 REQUESTS
;WITH RequestNumbers AS
(
    SELECT 1 AS Number
    UNION ALL
    SELECT Number + 1
    FROM RequestNumbers
    WHERE Number < 200
)
INSERT INTO Request
    (CustomerID, RequiredSkillID, Priority, Channel, ReceivedAt, Status)
SELECT
    ((Number - 1) % 10) + 1,
    ((Number - 1) % 10) + 1,
    Number % 6,
    CASE WHEN Number % 2 = 0 THEN 'Call' ELSE 'Chat' END,
    DATEADD(SECOND, -Number * 30, SYSUTCDATETIME()),
    CASE
        WHEN Number % 5 = 0 THEN 'Assigned'
        WHEN Number % 7 = 0 THEN 'Completed'
        ELSE 'Queued'
    END
FROM RequestNumbers
OPTION (MAXRECURSION 0);
GO

-- VERIFY
SELECT COUNT(*) AS TotalAgentSkills FROM AgentSkill;
SELECT COUNT(*) AS TotalRequests FROM Request;
GO



USE QueueFlowDB;
GO

-- 6. INSERT 10 ROUTING DECISIONS
INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
VALUES
(1, 1, 25),
(2, 2, 40),
(3, 3, 15),
(4, 4, 30),
(5, 6, 55),
(6, 8, 20),
(7, 9, 35),
(8, 10, 18),
(9, 1, 45),
(10, 2, 28);
GO

-- VERIFY ALL SIX TABLES
SELECT 'Agent' AS TableName, COUNT(*) AS TotalRecords FROM Agent
UNION ALL
SELECT 'Skill', COUNT(*) FROM Skill
UNION ALL
SELECT 'AgentSkill', COUNT(*) FROM AgentSkill
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Request', COUNT(*) FROM Request
UNION ALL
SELECT 'RoutingDecision', COUNT(*) FROM RoutingDecision;
GO


USE QueueFlowDB;
GO

-- 1. VERIFY RECORD COUNTS
SELECT 'Agent' AS TableName, COUNT(*) AS TotalRecords FROM Agent
UNION ALL
SELECT 'Skill', COUNT(*) FROM Skill
UNION ALL
SELECT 'AgentSkill', COUNT(*) FROM AgentSkill
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Request', COUNT(*) FROM Request
UNION ALL
SELECT 'RoutingDecision', COUNT(*) FROM RoutingDecision;
GO

-- 2. VERIFY FOREIGN KEY RELATIONSHIPS
SELECT
    r.RequestID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    s.SkillName,
    r.Priority,
    r.Channel,
    r.Status
FROM Request r
INNER JOIN Customer c ON r.CustomerID = c.CustomerID
INNER JOIN Skill s ON r.RequiredSkillID = s.SkillID;
GO

-- 3. VERIFY AGENT SKILLS
SELECT
    a.FirstName + ' ' + a.LastName AS AgentName,
    s.SkillName,
    ast.ProficiencyLevel
FROM AgentSkill ast
INNER JOIN Agent a ON ast.AgentID = a.AgentID
INNER JOIN Skill s ON ast.SkillID = s.SkillID;
GO

-- 4. VERIFY ROUTING DECISIONS
SELECT
    rd.DecisionID,
    rd.RequestID,
    a.FirstName + ' ' + a.LastName AS AgentName,
    rd.WaitSeconds
FROM RoutingDecision rd
INNER JOIN Agent a ON rd.AgentID = a.AgentID;
GO

-- 5. VERIFY INDEX
SELECT name AS IndexName
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Request')
AND name = 'IX_Request_Skill_Status';
GO
