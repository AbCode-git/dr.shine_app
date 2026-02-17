-- ============================================
-- STAFF VISIBILITY FIX
-- ============================================
-- Allows profiles with staff/washer roles to be viewed without a session.
-- This is necessary to support "Mock Admin" mode in standard UI flows.
-- Run this in your Supabase SQL Editor.
-- ============================================

DROP POLICY IF EXISTS "Profiles_Public_Staff_Select" ON public.profiles;
CREATE POLICY "Profiles_Public_Staff_Select" ON public.profiles
    FOR SELECT USING (role IN ('staff', 'washer'));

DO $$ 
BEGIN 
    RAISE NOTICE '✅ Staff visibility policy applied successfully.';
END $$;
