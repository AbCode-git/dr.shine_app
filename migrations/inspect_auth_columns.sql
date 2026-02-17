-- ============================================
-- AUTH SCHEMA INSPECTOR
-- ============================================
-- Purpose: See the EXACT columns of auth.users
-- ============================================

SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'auth' 
AND table_name = 'users'
ORDER BY ordinal_position;
