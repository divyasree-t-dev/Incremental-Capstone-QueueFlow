
USE QueueFlowDB;
GO

-- TEST 1: UNIQUE SkillName

-- Valid insert: should succeed
INSERT INTO Skill (SkillName)
VALUES ('ConstraintTestSkill');

PRINT 'PASS: Unique SkillName accepts a new value';

-- Invalid insert: duplicate should fail
BEGIN TRY
    INSERT INTO Skill (SkillName)
    VALUES ('ConstraintTestSkill');

    PRINT 'FAIL: Duplicate SkillName was accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Duplicate SkillName rejected';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- TEST 2: UNIQUE AgentID + SkillID

-- Valid insert: Agent 1 + Skill 2
INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
VALUES (1, 2, 4);

PRINT 'PASS: Unique Agent-Skill combination accepted';

-- Invalid insert: same combination again
BEGIN TRY
    INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
    VALUES (1, 2, 5);

    PRINT 'FAIL: Duplicate Agent-Skill combination accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Duplicate Agent-Skill combination rejected';
    PRINT ERROR_MESSAGE();
END CATCH;
GO



USE QueueFlowDB;
GO

-- 1. AGENT STATUS
-- Valid
INSERT INTO Agent (FirstName, LastName, Status)
VALUES ('Test', 'Agent', 'Available');

-- Invalid
BEGIN TRY
    INSERT INTO Agent (FirstName, LastName, Status)
    VALUES ('Invalid', 'Agent', 'Unknown');
    PRINT 'FAIL: Invalid Agent Status accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Agent Status rejected';
END CATCH;
GO

-- 2. AGENTSKILL PROFICIENCY
-- Valid
INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
VALUES (1, 3, 3);

-- Invalid
BEGIN TRY
    INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
    VALUES (1, 4, 6);
    PRINT 'FAIL: Invalid Proficiency accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Proficiency rejected';
END CATCH;
GO

-- 3. CUSTOMER TIER
-- Valid
INSERT INTO Customer (FirstName, LastName, Tier)
VALUES ('Test', 'Customer', 'Premium');

-- Invalid
BEGIN TRY
    INSERT INTO Customer (FirstName, LastName, Tier)
    VALUES ('Invalid', 'Customer', 'Gold');
    PRINT 'FAIL: Invalid Customer Tier accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Customer Tier rejected';
END CATCH;
GO

-- 4. REQUEST PRIORITY
-- Valid
INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
VALUES (1, 1, 3, 'Call');

-- Invalid
BEGIN TRY
    INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
    VALUES (1, 1, 10, 'Call');
    PRINT 'FAIL: Invalid Priority accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Priority rejected';
END CATCH;
GO

-- 5. REQUEST CHANNEL
-- Invalid
BEGIN TRY
    INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
    VALUES (1, 1, 2, 'Email');
    PRINT 'FAIL: Invalid Channel accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Channel rejected';
END CATCH;
GO

-- 6. REQUEST STATUS
-- Invalid
BEGIN TRY
    UPDATE Request
    SET Status = 'Invalid'
    WHERE RequestID = 1;
    PRINT 'FAIL: Invalid Request Status accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid Request Status rejected';
END CATCH;
GO

-- 7. ROUTING DECISION WAIT
-- Invalid
BEGIN TRY
    INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
    VALUES (1, 1, -5);
    PRINT 'FAIL: Negative WaitSeconds accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Negative WaitSeconds rejected';
END CATCH;
GO


USE QueueFlowDB;
GO

-- 1. AGENT DEFAULT
INSERT INTO Agent (FirstName, LastName)
VALUES ('Default', 'Agent');

SELECT AgentID, Status
FROM Agent
WHERE FirstName = 'Default';
GO

-- 2. CUSTOMER DEFAULT
INSERT INTO Customer (FirstName, LastName)
VALUES ('Default', 'Customer');

SELECT CustomerID, Tier
FROM Customer
WHERE FirstName = 'Default';
GO

-- 3. REQUEST DEFAULTS
INSERT INTO Request (CustomerID, RequiredSkillID, Channel)
VALUES (1, 1, 'Call');

SELECT RequestID, Priority, ReceivedAt, Status
FROM Request
WHERE RequestID = SCOPE_IDENTITY();
GO

-- 4. ROUTING DECISION DEFAULT
INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
VALUES (1, 1, 10);

SELECT TOP 1 DecisionID, RoutedAt
FROM RoutingDecision
ORDER BY DecisionID DESC;
GO



USE QueueFlowDB;
GO

-- 1. AGENTSKILL: VALID FOREIGN KEYS
INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
VALUES (2, 1, 4);

PRINT 'PASS: Valid AgentID and SkillID accepted';

-- Invalid AgentID
BEGIN TRY
    INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
    VALUES (999999, 2, 3);
    PRINT 'FAIL: Invalid AgentID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid AgentID rejected';
END CATCH;

-- Invalid SkillID
BEGIN TRY
    INSERT INTO AgentSkill (AgentID, SkillID, ProficiencyLevel)
    VALUES (2, 999999, 3);
    PRINT 'FAIL: Invalid SkillID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid SkillID rejected';
END CATCH;
GO

-- 2. REQUEST: VALID FOREIGN KEYS
INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
VALUES (1, 2, 2, 'Call');

PRINT 'PASS: Valid CustomerID and SkillID accepted';

-- Invalid CustomerID
BEGIN TRY
    INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
    VALUES (999999, 1, 2, 'Call');
    PRINT 'FAIL: Invalid CustomerID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid CustomerID rejected';
END CATCH;

-- Invalid RequiredSkillID
BEGIN TRY
    INSERT INTO Request (CustomerID, RequiredSkillID, Priority, Channel)
    VALUES (1, 999999, 2, 'Call');
    PRINT 'FAIL: Invalid RequiredSkillID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid RequiredSkillID rejected';
END CATCH;
GO

-- 3. ROUTING DECISION: VALID FOREIGN KEYS
INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
VALUES (1, 1, 20);

PRINT 'PASS: Valid RequestID and AgentID accepted';

-- Invalid RequestID
BEGIN TRY
    INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
    VALUES (999999, 1, 20);
    PRINT 'FAIL: Invalid RequestID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid RequestID rejected';
END CATCH;

-- Invalid AgentID
BEGIN TRY
    INSERT INTO RoutingDecision (RequestID, AgentID, WaitSeconds)
    VALUES (1, 999999, 20);
    PRINT 'FAIL: Invalid AgentID accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS: Invalid AgentID rejected';
END CATCH;
GO
