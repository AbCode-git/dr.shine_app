-- ============================================
-- COMPREHENSIVE CLEANUP SCRIPT (Truncates Data)
-- ============================================
-- Purpose: Removes ALL user data, bookings, and profiles to give a fresh start.
-- Does NOT drop tables or functions. Preserves the schema.
-- ============================================

DO $$
DECLARE
    v_profile_count INTEGER;
    v_user_count INTEGER;
    v_booking_count INTEGER;
BEGIN
    RAISE NOTICE 'Starting comprehensive data cleanup...';

    -- 1. TRUNCATE operational tables first (to remove references)
    --    This clears all wash history and status logs.
    TRUNCATE TABLE public.bookings CASCADE;
    TRUNCATE TABLE public.status CASCADE;
    -- Optional: TRUNCATE public.inventory CASCADE; -- Uncomment if you want to clear inventory too

    GET DIAGNOSTICS v_booking_count = ROW_COUNT;
    RAISE NOTICE 'Cleared bookings and operational data.';

    -- 2. Delete ALL Profiles
    DELETE FROM public.profiles;
    GET DIAGNOSTICS v_profile_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % profiles.', v_profile_count;

    -- 3. Delete ALL Auth Users (The Nuclear Option)
    --    This removes everyone from the Supabase Authentication panel.
    --    Only do this if you are sure you want to require re-registration for EVERYONE.
    DELETE FROM auth.users; 
    GET DIAGNOSTICS v_user_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % auth users.', v_user_count;

    -- 4. Clean up Identities (just in case cascade missed bits, though auth.users cascade usually handles it)
    DELETE FROM auth.identities;

    RAISE NOTICE '==================================================';
    RAISE NOTICE '✅ COMPREHENSIVE CLEANUP COMPLETE';
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '  - Profiles Removed: %', v_profile_count;
    RAISE NOTICE '  - Auth Users Removed: %', v_user_count;
    RAISE NOTICE '  - Operational Tables: Truncated';
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'You can now run "migrations/seed_test_data.sql" if you need fresh test accounts.';
END $$;
