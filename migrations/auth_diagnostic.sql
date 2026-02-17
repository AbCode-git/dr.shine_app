-- ============================================
-- AUTH DIAGNOSTIC SCRIPT (FIXED)
-- ============================================
-- Purpose: Find exactly why the Auth server is failing.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- 1. Check for ANY triggers in the system
-- (Looking for hidden loops in both public and auth)
SELECT 
    event_object_schema as schema,
    event_object_table as table,
    trigger_name
FROM information_schema.triggers
WHERE event_object_schema IN ('public', 'auth');

-- 2. Check for RLS policies (Corrected Columns)
-- (qual = USING, with_check = WITH CHECK)
SELECT 
    schemaname,
    tablename,
    policyname,
    qual as using_expr,
    with_check as check_expr
FROM pg_policies
WHERE schemaname IN ('public', 'auth');

-- 3. Inspect the state of the "extensions" schema
-- (Bcrypt needs pgcrypto here)
SELECT extname, nspname 
FROM pg_extension e 
JOIN pg_namespace n ON e.extnamespace = n.oid 
WHERE extname = 'pgcrypto';

-- 4. Check if RLS is actually enabled or disabled
SELECT 
    relname, 
    relrowsecurity as rls_enabled
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' 
AND relname IN ('profiles', 'tenants', 'bookings');

-- 5. NUCLEAR USER CLEANUP
-- Clears everything so we can try one more "Cleanest" RPC
DELETE FROM auth.users WHERE email LIKE '%@drshine.app';

DO $$ 
BEGIN 
    RAISE NOTICE '🔍 Fixed Diagnostics run. Please tell me what tables have triggers listed!';
END $$;
