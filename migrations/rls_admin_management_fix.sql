-- ============================================
-- RLS ADMIN MANAGEMENT FIX
-- ============================================
-- Allows Branch Admins to manage profiles within their tenant.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- 1. Helper function to check for Admin role
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'admin' FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

-- 2. Allow Admins to insert new staff/washer profiles for their own branch
DROP POLICY IF EXISTS "Profiles_Admin_Insert" ON public.profiles;
CREATE POLICY "Profiles_Admin_Insert" ON public.profiles
    FOR INSERT WITH CHECK (
        is_admin() 
        AND tenant_id = (SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1)
    );

-- 3. Allow Admins to update team member profiles within their branch
DROP POLICY IF EXISTS "Profiles_Admin_Update" ON public.profiles;
CREATE POLICY "Profiles_Admin_Update" ON public.profiles
    FOR UPDATE USING (
        is_admin() 
        AND tenant_id = (SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1)
    );

-- 4. Allow Admins to delete staff/washers in their branch
DROP POLICY IF EXISTS "Profiles_Admin_Delete" ON public.profiles;
CREATE POLICY "Profiles_Admin_Delete" ON public.profiles
    FOR DELETE USING (
        is_admin() 
        AND tenant_id = (SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1)
        AND role IN ('staff', 'washer')
    );

DO $$ 
BEGIN 
    RAISE NOTICE '✅ RLS Admin Management policies applied successfully.';
END $$;
