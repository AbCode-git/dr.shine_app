-- ============================================
-- RLS NUCLEAR FIX - FORCED RECURSION REMOVAL
-- ============================================
-- This script forcefully drops ALL policies on 'profiles' 
-- and 'tenants' to stop the 500 Internal Server Error.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- 1. FORCE DROP ALL POLICIES on profiles and tenants
-- (This ensures no old recursive policies remain hidden)
DO $$ 
DECLARE 
    pol record;
BEGIN 
    -- Drop all on profiles
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'profiles' AND schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY %I ON public.profiles', pol.policyname);
    END LOOP;
    
    -- Drop all on tenants
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'tenants' AND schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY %I ON public.tenants', pol.policyname);
    END LOOP;

    RAISE NOTICE '✅ All old policies dropped successfully.';
END $$;

-- 2. Restore Helper Functions (Both Names for Safety)
-- SECURITY DEFINER is critical to prevent recursion.
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

CREATE OR REPLACE FUNCTION public.get_current_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'superadmin' FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

-- 3. RECREATE MINIMAL RECURSION-SAFE POLICIES

-- --- TENANTS ---
-- Public view for sign-up form
CREATE POLICY "Tenants_Public_Read" ON public.tenants FOR SELECT USING (true);
-- Super Admin full access
CREATE POLICY "Tenants_Super_Access" ON public.tenants FOR ALL USING (is_super_admin());

-- --- PROFILES ---
-- Rule 1: Self Access (BASE PRIORITY - NO RECURSION)
-- This is what GoTrue uses during login. It must be as simple as possible.
CREATE POLICY "Profiles_Self_Access" ON public.profiles 
    FOR ALL USING (auth.uid() = id);

-- Rule 2: Self Insert (For Sign-up)
CREATE POLICY "Profiles_Self_Insert" ON public.profiles 
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Rule 3: Team Visibility (See others in branch)
-- auth.uid() != id prevents this policy from checking ITSELF.
CREATE POLICY "Profiles_Team_Visibility" ON public.profiles 
    FOR SELECT USING (
        auth.uid() != id 
        AND tenant_id = get_user_tenant_id()
    );

-- Rule 4: Super Admin bypass
CREATE POLICY "Profiles_Super_Admin_Bypass" ON public.profiles 
    FOR ALL USING (
        auth.uid() != id 
        AND is_super_admin()
    );

-- --- OPERATIONAL TABLES ---
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Bookings_Isolation" ON public.bookings;
CREATE POLICY "Bookings_Isolation" ON public.bookings FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());

ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Inventory_Isolation" ON public.inventory;
CREATE POLICY "Inventory_Isolation" ON public.inventory FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());

ALTER TABLE public.status ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Status_Isolation" ON public.status;
CREATE POLICY "Status_Isolation" ON public.status FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());

DO $$ 
BEGIN 
    RAISE NOTICE '🚀 Nuclear Fix Applied! Please try to log in again.';
END $$;
