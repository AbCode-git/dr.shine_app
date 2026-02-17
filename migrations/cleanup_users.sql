-- ============================================
-- CLEANUP SCRIPT: DELETE ALL TEST USERS
-- ============================================
-- Purpose: Remove all accounts created during testing
-- domain: @drshine.app
-- ============================================

-- 1. DELETE from auth.users
-- This will automatically delete profiles due to Foreign Key CASCADE
DELETE FROM auth.users 
WHERE email LIKE '%@drshine.app';

-- 2. (Optional) Clear specific identities if needed
DELETE FROM auth.identities
WHERE provider_id LIKE '%@drshine.app';

DO $$ 
BEGIN 
    RAISE NOTICE '🧹 Cleanup complete! All @drshine.app users have been removed.';
END $$;
