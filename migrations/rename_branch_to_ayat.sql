-- Update the branch name in the live database
UPDATE tenants 
SET name = 'Main Branch - Ayat' 
WHERE name = 'Main Branch - Bole';

-- Verify the change
SELECT * FROM tenants;
