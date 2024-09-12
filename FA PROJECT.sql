CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Accounts (
    AccountID SERIAL PRIMARY KEY,
    UserID INT REFERENCES Users(UserID),
    AccountName VARCHAR(100) NOT NULL,
    AccountType VARCHAR(50) NOT NULL,  -- E.g., Checking, Savings
    Balance DECIMAL(15, 2) DEFAULT 0.00,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Transactions (
    TransactionID SERIAL PRIMARY KEY,
    AccountID INT REFERENCES Accounts(AccountID),
    TransactionDate DATE NOT NULL,
    Category VARCHAR(50) NOT NULL,  -- E.g., Groceries, Rent, Entertainment
    Amount DECIMAL(15, 2) NOT NULL,
    TransactionType VARCHAR(50) NOT NULL,  -- E.g., Credit, Debit
    Description TEXT
);
CREATE TABLE Budgets (
    BudgetID SERIAL PRIMARY KEY,
    UserID INT REFERENCES Users(UserID),
    Category VARCHAR(50) NOT NULL,
    BudgetAmount DECIMAL(15, 2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);
CREATE TABLE SavingsGoals (
    GoalID SERIAL PRIMARY KEY,
    UserID INT REFERENCES Users(UserID),
    GoalName VARCHAR(100) NOT NULL,
    TargetAmount DECIMAL(15, 2) NOT NULL,
    CurrentAmount DECIMAL(15, 2) DEFAULT 0.00,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);
INSERT INTO Users (UserName, Email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');
INSERT INTO Accounts (UserID, AccountName, AccountType, Balance) VALUES
(1, 'John''s Checking', 'Checking', 5000.00),
(1, 'John''s Savings', 'Savings', 12000.00),
(2, 'Jane''s Checking', 'Checking', 8000.00);
INSERT INTO Transactions (AccountID, TransactionDate, Category, Amount, TransactionType, Description) VALUES
(1, '2024-08-01', 'Groceries', 150.00, 'Debit', 'Weekly groceries at Walmart'),
(2, '2024-08-02', 'Rent', 1200.00, 'Debit', 'Monthly apartment rent'),
(3, '2024-08-03', 'Salary', 3000.00, 'Credit', 'Monthly salary');
INSERT INTO Budgets (UserID, Category, BudgetAmount, StartDate, EndDate) VALUES
(1, 'Groceries', 600.00, '2024-08-01', '2024-08-31'),
(2, 'Rent', 1200.00, '2024-08-01', '2024-08-31');
INSERT INTO SavingsGoals (UserID, GoalName, TargetAmount, StartDate, EndDate) VALUES
(1, 'Vacation Fund', 5000.00, '2024-01-01', '2024-12-31'),
(2, 'Emergency Fund', 10000.00, '2024-01-01', '2024-12-31');

--Analysis
--Monthly Spending by Category
SELECT Category, SUM(Amount) AS TotalSpent
FROM Transactions
WHERE TransactionType = 'Debit' AND EXTRACT(MONTH FROM TransactionDate) = 8
GROUP BY Category;

--Budget Adherence
SELECT b.Category, b.BudgetAmount, COALESCE(SUM(t.Amount), 0) AS SpentAmount,
       (b.BudgetAmount - COALESCE(SUM(t.Amount), 0)) AS AmountRemaining
FROM Budgets b
LEFT JOIN Transactions t ON b.UserID = t.AccountID AND b.Category = t.Category
AND t.TransactionDate BETWEEN b.StartDate AND b.EndDate
GROUP BY b.Category, b.BudgetAmount;

--Savings Progress
SELECT GoalName, TargetAmount, CurrentAmount,
       (CurrentAmount / TargetAmount * 100) AS ProgressPercentage
FROM SavingsGoals;

--Using loops to create more rows in the tables 
--Transactions Table
DO
$$
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO Transactions (AccountID, TransactionDate, Category, Amount, TransactionType, Description)
        VALUES (
            (SELECT AccountID FROM Accounts ORDER BY RANDOM() LIMIT 1),  -- Randomly select an AccountID
            CURRENT_DATE - (i % 30),  -- Spread dates over the last 30 days
            CASE WHEN i % 5 = 0 THEN 'Groceries'
                 WHEN i % 5 = 1 THEN 'Rent'
                 WHEN i % 5 = 2 THEN 'Entertainment'
                 WHEN i % 5 = 3 THEN 'Utilities'
                 ELSE 'Other' END,  -- Cycle through categories
            ROUND(CAST((RANDOM() * 200 + 10) AS numeric), 2),  -- Generate a random amount between $10 and $210
            CASE WHEN i % 2 = 0 THEN 'Debit' ELSE 'Credit' END,  -- Alternate between Debit and Credit
            'Generated transaction ' || i  -- Description
        );
    END LOOP;
END
$$;

SELECT * FROM Transactions;

--Accounts table
DO
$$
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO Accounts (UserID, AccountName, AccountType, Balance)
        VALUES (
            (SELECT UserID FROM Users ORDER BY RANDOM() LIMIT 1),  -- Randomly select a UserID
            'Account ' || i,  -- Create unique account names
            CASE WHEN i % 2 = 0 THEN 'Checking' ELSE 'Savings' END,  -- Alternate between Checking and Savings
            ROUND(CAST((RANDOM() * 10000) AS numeric), 2)  -- Generate a random balance up to $10,000
        );
    END LOOP;
END
$$;

SELECT * FROM Accounts;

--Budgets Table 
DO
$$
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO Budgets (UserID, Category, BudgetAmount, StartDate, EndDate)
        VALUES (
            (SELECT UserID FROM Users ORDER BY RANDOM() LIMIT 1),  -- Randomly select a UserID
            CASE WHEN i % 5 = 0 THEN 'Groceries'
                 WHEN i % 5 = 1 THEN 'Rent'
                 WHEN i % 5 = 2 THEN 'Entertainment'
                 WHEN i % 5 = 3 THEN 'Utilities'
                 ELSE 'Miscellaneous' END,  -- Cycle through categories
            ROUND(CAST((RANDOM() * 1000 + 100) AS numeric), 2),  -- Generate a budget amount between $100 and $1,100
            CURRENT_DATE - (i % 60),  -- Start dates within the last 60 days
            CURRENT_DATE + (i % 30)  -- End dates within the next 30 days
        );
    END LOOP;
END
$$;

SELECT * FROM Budgets;

--Savings Goals Table
DO
$$
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO SavingsGoals (UserID, GoalName, TargetAmount, CurrentAmount, StartDate, EndDate)
        VALUES (
            (SELECT UserID FROM Users ORDER BY RANDOM() LIMIT 1),  -- Randomly select a UserID
            'Goal ' || i,  -- Create unique goal names
            ROUND(CAST((RANDOM() * 5000 + 500) AS numeric), 2),  -- Generate a target amount between $500 and $5,500
            ROUND(CAST((RANDOM() * 3000) AS numeric), 2),  -- Generate a current amount up to $3,000
            CURRENT_DATE - (i % 120),  -- Start dates within the last 120 days
            CURRENT_DATE + (i % 60)  -- End dates within the next 60 days
        );
    END LOOP;
END
$$;

SELECT * FROM Savingsgoals

--Counting the rows
SELECT COUNT(*) FROM Transactions;
SELECT COUNT(*) FROM Accounts;
SELECT COUNT(*) FROM Budgets;
SELECT COUNT(*) FROM SavingsGoals;

--Spreading data across 6 months
-- transactions table
DO
$$
BEGIN
    FOR i IN 1..5 LOOP  -- Loop to create 5 additional months of data
        INSERT INTO Transactions (AccountID, TransactionDate, Category, Amount, TransactionType, Description)
        SELECT 
            AccountID,
            TransactionDate - (i * INTERVAL '1 month') AS TransactionDate,  -- Adjust date by i months back
            Category,
            Amount,
            TransactionType,
            Description || ' (Duplicated for month ' || (8 - i) || ')'  -- Add note to description
        FROM Transactions
        WHERE EXTRACT(MONTH FROM TransactionDate) = 8;  -- Only duplicate August data
    END LOOP;
END
$$;

DO
$$
BEGIN
    FOR i IN 1..6 LOOP  -- Loop through all 6 months
        UPDATE Transactions
        SET Amount = ROUND((Amount * (0.8 + (i * 0.1)) * RANDOM())::numeric, 2)  -- Apply variability
        WHERE EXTRACT(MONTH FROM TransactionDate) = (8 - (i - 1));  -- Adjust amounts for each month
    END LOOP;
END
$$;


--Budgets table
DO
$$
BEGIN
    FOR i IN 1..5 LOOP  -- Loop to create 5 additional months of data
        INSERT INTO Budgets (UserID, Category, BudgetAmount, StartDate, EndDate)
        SELECT 
            UserID,
            Category,
            BudgetAmount,
            StartDate - (i * INTERVAL '1 month') AS StartDate,  -- Adjust StartDate
            EndDate - (i * INTERVAL '1 month') AS EndDate  -- Adjust EndDate
        FROM Budgets
        WHERE EXTRACT(MONTH FROM StartDate) = 8;  -- Only duplicate August data
    END LOOP;
END
$$;

--Savingsgoals table 
DO
$$
BEGIN
    FOR i IN 1..5 LOOP  -- Loop to create 5 additional months of data
        INSERT INTO SavingsGoals (UserID, GoalName, TargetAmount, CurrentAmount, StartDate, EndDate)
        SELECT 
            UserID,
            GoalName || ' (Duplicated for month ' || (8 - i) || ')',  -- Modify GoalName for clarity
            TargetAmount,
            CurrentAmount,
            StartDate - (i * INTERVAL '1 month') AS StartDate,  -- Adjust StartDate
            EndDate - (i * INTERVAL '1 month') AS EndDate  -- Adjust EndDate
        FROM SavingsGoals
        WHERE EXTRACT(MONTH FROM StartDate) = 8;  -- Only duplicate August data
    END LOOP;
END
$$;

--Accounts table 
DO
$$
BEGIN
    UPDATE Accounts
    SET CreatedAt = CreatedAt - (FLOOR(RANDOM() * 5 + 1) * INTERVAL '1 month')
    WHERE EXTRACT(MONTH FROM CreatedAt) = 8;  -- Adjusts August accounts to be distributed over the past 5 months
END
$$;


--Budget Optimization and Recommendation System
--Analyze Spending vs. Budget Data

--Collect Historical Spending Data
SELECT 
    EXTRACT(MONTH FROM TransactionDate) AS Month,
    Category,
    SUM(Amount) AS TotalSpent
FROM Transactions
WHERE TransactionType = 'Debit'
GROUP BY Month, Category
ORDER BY Month, Category;

--Compare Spending to Budgets
SELECT 
    b.UserID,
    b.Category,
    b.BudgetAmount,
    COALESCE(SUM(t.Amount), 0) AS ActualSpent,
    (b.BudgetAmount - COALESCE(SUM(t.Amount), 0)) AS BudgetVariance
FROM Budgets b
LEFT JOIN Transactions t 
    ON b.UserID = t.AccountID 
    AND b.Category = t.Category 
    AND t.TransactionDate BETWEEN b.StartDate AND b.EndDate
GROUP BY b.UserID, b.Category, b.BudgetAmount;

--Summarize by Category and Month
SELECT 
    EXTRACT(MONTH FROM TransactionDate) AS Month,
    Category,
    SUM(Amount) AS TotalSpent
FROM Transactions
WHERE TransactionType = 'Debit'
GROUP BY Month, Category
ORDER BY Month, TotalSpent DESC;

--  Compare Actual Spending to Budget
SELECT 
    b.Category,
    SUM(b.BudgetAmount) AS TotalBudgeted,
    SUM(COALESCE(t.Amount, 0)) AS TotalSpent,
    (SUM(b.BudgetAmount) - SUM(COALESCE(t.Amount, 0))) AS BudgetVariance
FROM Budgets b
LEFT JOIN Transactions t 
    ON b.UserID = t.AccountID 
    AND b.Category = t.Category 
    AND t.TransactionDate BETWEEN b.StartDate AND b.EndDate
GROUP BY b.Category
ORDER BY BudgetVariance DESC;

--Insights (1)
-- Groceries: Actual spending is far below budget. Consider reducing budget to 300,000 - 350,000.
-- Utilities: Actual spending  vs budget  suggests reducing budget to 350,000 - 400,000.
-- Entertainment: Actual spending  vs budget  indicates budget can be reduced to ~300,000.
-- Rent: Actual spending  is much lower than budget). Adjust budget closer to 300,000.
-- Miscellaneous: No spending recorded. Review if this category is needed or reallocate budget elsewhere.


--KPIs for Monitoring

--Create Stored Procedures for KPIs
--Savings Rate Procedure
CREATE OR REPLACE PROCEDURE CalculateSavingsRate()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO KPI_Results (KPI_Name, KPI_Value, CalculatedAt)
    SELECT 
        'Savings Rate' AS KPI_Name,
        (SUM(CASE WHEN Category = 'Savings' THEN Amount ELSE 0 END) / SUM(Amount)) * 100 AS KPI_Value,
        CURRENT_TIMESTAMP AS CalculatedAt
    FROM Transactions
    WHERE TransactionType = 'Credit';
END;
$$;

--Budget Adherence Procedure
CREATE OR REPLACE PROCEDURE CalculateBudgetAdherence()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO KPI_Results (KPI_Name, KPI_Value, CalculatedAt)
    SELECT 
        'Budget Adherence' AS KPI_Name,
        (SUM(b.BudgetAmount) - SUM(COALESCE(t.Amount, 0))) / SUM(b.BudgetAmount) * 100 AS KPI_Value,
        CURRENT_TIMESTAMP AS CalculatedAt
    FROM Budgets b
    LEFT JOIN Transactions t 
        ON b.UserID = t.AccountID 
        AND b.Category = t.Category 
        AND t.TransactionDate BETWEEN b.StartDate AND b.EndDate;
END;
$$;


--Spending-to-Income Ratio Procedure
CREATE OR REPLACE PROCEDURE CalculateSpendingToIncomeRatio()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO KPI_Results (KPI_Name, KPI_Value, CalculatedAt)
    WITH TotalIncome AS (
        SELECT SUM(Amount) AS Income
        FROM Transactions
        WHERE TransactionType = 'Credit'
    ),
    TotalSpending AS (
        SELECT SUM(Amount) AS Spending
        FROM Transactions
        WHERE TransactionType = 'Debit'
    )
    SELECT 
        'Spending-to-Income Ratio' AS KPI_Name,
        (Spending / Income) * 100 AS KPI_Value,
        CURRENT_TIMESTAMP AS CalculatedAt
    FROM TotalIncome, TotalSpending;
END;
$$;

--Set Up Automated Execution
CREATE EXTENSION pg_cron;

SELECT cron.schedule('0 0 * * *', 'CALL CalculateSavingsRate()');
SELECT cron.schedule('0 0 * * *', 'CALL CalculateBudgetAdherence()');
SELECT cron.schedule('0 0 * * *', 'CALL CalculateSpendingToIncomeRatio()');

--Automate Recommendations
CREATE OR REPLACE PROCEDURE GenerateBudgetRecommendations()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Recommendations (UserID, Category, Recommendation, GeneratedAt)
    SELECT 
        b.UserID,
        b.Category,
        CASE
            WHEN (b.BudgetAmount - COALESCE(SUM(t.Amount), 0)) > 1000 THEN 
                'Consider reducing the budget for ' || b.Category || ' by ' || (b.BudgetAmount - SUM(t.Amount))::text || ' units.'
            WHEN (COALESCE(SUM(t.Amount), 0) - b.BudgetAmount) > 1000 THEN
                'Consider increasing the budget for ' || b.Category || ' by ' || (SUM(t.Amount) - b.BudgetAmount)::text || ' units.'
            ELSE
                'Budget is well-balanced for ' || b.Category
        END AS Recommendation,
        CURRENT_TIMESTAMP AS GeneratedAt
    FROM Budgets b
    LEFT JOIN Transactions t 
        ON b.UserID = t.AccountID 
        AND b.Category = t.Category 
        AND t.TransactionDate BETWEEN b.StartDate AND b.EndDate
    GROUP BY b.UserID, b.Category, b.BudgetAmount;
END;
$$;

-- Automate Execution
SELECT cron.schedule('0 0 1 * *', 'CALL GenerateBudgetRecommendations()');







