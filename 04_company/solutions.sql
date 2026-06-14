--Задача 1
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        EmployeeID, Name, ManagerID, DepartmentID, RoleID
    FROM 
        Employees 
    WHERE 
        EmployeeID = 1
        
    UNION ALL
    
    SELECT 
        e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    FROM 
        Employees e
    JOIN 
        EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    eh.EmployeeID,
    eh.Name,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName) 
        FROM Projects p 
        WHERE p.DepartmentID = eh.DepartmentID
    ) AS Projects,
    (
        SELECT GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName) 
        FROM Tasks t 
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS Tasks
FROM 
    EmployeeHierarchy eh
LEFT JOIN 
    Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN 
    Roles r ON eh.RoleID = r.RoleID
ORDER BY 
    eh.Name ASC;

--Задача 2
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        EmployeeID, Name, ManagerID, DepartmentID, RoleID
    FROM 
        Employees 
    WHERE 
        EmployeeID = 1
        
    UNION ALL
    
    SELECT 
        e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    FROM 
        Employees e
    JOIN 
        EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    eh.EmployeeID AS EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID AS ManagerID,
    d.DepartmentName AS DepartmentName,
    r.RoleName AS RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName) 
        FROM Projects p 
        WHERE p.DepartmentID = eh.DepartmentID
    ) AS ProjectNames,
    (
        SELECT GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName) 
        FROM Tasks t 
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS TaskNames,
    (
        SELECT COUNT(t.TaskID) 
        FROM Tasks t 
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS TotalTasks,
    (
        SELECT COUNT(sub.EmployeeID) 
        FROM Employees sub 
        WHERE sub.ManagerID = eh.EmployeeID
    ) AS TotalSubordinates
FROM 
    EmployeeHierarchy eh
LEFT JOIN 
    Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN 
    Roles r ON eh.RoleID = r.RoleID
ORDER BY 
    EmployeeName ASC;

--Задача 3
WITH RECURSIVE SubHierarchy AS (
    SELECT 
        ManagerID AS AnchorManagerID, 
        EmployeeID AS SubordinateID
    FROM 
        Employees 
    WHERE 
        ManagerID IS NOT NULL
        
    UNION ALL
    
    SELECT 
        sh.AnchorManagerID, 
        e.EmployeeID
    FROM 
        Employees e
    JOIN 
        SubHierarchy sh ON e.ManagerID = sh.SubordinateID
)
SELECT 
    e.EmployeeID AS EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID AS ManagerID,
    d.DepartmentName AS DepartmentName,
    r.RoleName AS RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName) 
        FROM Projects p 
        WHERE p.DepartmentID = e.DepartmentID
    ) AS ProjectNames,
    (
        SELECT GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName) 
        FROM Tasks t 
        WHERE t.AssignedTo = e.EmployeeID
    ) AS TaskNames,
    (
        SELECT COUNT(DISTINCT SubordinateID) 
        FROM SubHierarchy 
        WHERE AnchorManagerID = e.EmployeeID
    ) AS TotalSubordinates
FROM 
    Employees e
JOIN 
    Roles r ON e.RoleID = r.RoleID
LEFT JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID
WHERE 
    r.RoleName = 'Менеджер' 
    AND (
        SELECT COUNT(DISTINCT SubordinateID) 
        FROM SubHierarchy 
        WHERE AnchorManagerID = e.EmployeeID
    ) > 0
ORDER BY 
    EmployeeName ASC;
