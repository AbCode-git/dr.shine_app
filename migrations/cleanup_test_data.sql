-- ============================================
-- CLEANUP TEST DATA SCIPT
-- ============================================
-- Purpose: Removes the specific test accounts created during development.
-- Safely deletes from auth.users (which should cascade to profiles), 
-- but also explicitly targets profiles to be sure.
-- ============================================

DO $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    RAISE NOTICE 'Starting cleanup of test users...';

    -- 1. Delete from public.profiles first (to avoid FK constraints if no cascade)
    WITH deleted_profiles AS (
        DELETE FROM public.profiles 
        WHERE "phoneNumber" IN (
            '+251911234567', -- Test Super Admin
            '+251922345678', -- Test Manager
            '+251933456789', -- Test Staff
            '+251910627651'  -- Test Admin (Abrilo)
        )
        RETURNING id
    )
    SELECT count(*) INTO v_deleted_count FROM deleted_profiles;
    
    RAISE NOTICE 'Deleted % profiles.', v_deleted_count;

    -- 2. Delete from auth.users
    WITH deleted_users AS (
        DELETE FROM auth.users 
        WHERE email IN (
            '+251911234567@drshine.app', -- Test Super Admin
            '+251922345678@drshine.app', -- Test Manager
            '+251933456789@drshine.app', -- Test Staff
            '+251910627651@drshine.app'  -- Test Admin (Abrilo)
        )
        RETURNING id
    )
    SELECT count(*) INTO v_deleted_count FROM deleted_users;

    RAISE NOTICE 'Deleted % auth users.', v_deleted_count;

    RAISE NOTICE '✅ Cleanup complete.';
END $$;
