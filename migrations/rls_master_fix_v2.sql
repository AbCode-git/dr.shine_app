-- ============================================
-- MASTER RLS FIX v2 - RESOLVES LOGIN 500 ERRORS
-- ============================================
-- This script fixes recursion and search path issues.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- 1. Setup Safe Helper Functions (Qualified and Robust)
-- We include 'auth' in search_path and qualify 'public.profiles'
CREATE OR REPLACE FUNCTION public.get_current_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

CREATE OR REPLACE FUNCTION public.check_is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'superadmin' FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, auth;

-- 2. Drop EVERY related policy to ensure a clean slate
-- We'll drop both old and new names just in case
DROP POLICY IF EXISTS "Profiles access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Owner access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Self access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Self insert" ON profiles;
DROP POLICY IF EXISTS "Profiles - Tenant visibility" ON profiles;
DROP POLICY IF EXISTS "Profiles - Team visibility" ON profiles;
DROP POLICY IF EXISTS "Profiles - Manager management" ON profiles;
DROP POLICY IF EXISTS "Profiles - Super Admin bypass" ON profiles;

DROP POLICY IF EXISTS "Users can view their tenant" ON tenants;
DROP POLICY IF EXISTS "Public can view branch names" ON tenants;
DROP POLICY IF EXISTS "Tenants - Public view" ON tenants;
DROP POLICY IF EXISTS "Tenants - Super Admin access" ON tenants;
DROP POLICY IF EXISTS "Super admins can view all tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can create tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can delete tenants" ON tenants;

DROP POLICY IF EXISTS "Tenant isolation for bookings" ON bookings;
DROP POLICY IF EXISTS "Tenant isolation for inventory" ON inventory;
DROP POLICY IF EXISTS "Tenant isolation for status" ON status;
DROP POLICY IF EXISTS "Bookings - Tenant isolation" ON bookings;
DROP POLICY IF EXISTS "Inventory - Tenant isolation" ON inventory;
DROP POLICY IF EXISTS "Status - Tenant isolation" ON status;

-- 3. RECREATE ULTRA-SAFE POLICIES

-- --- TENANTS ---
-- Allow unauthenticated sign-up form to see names
CREATE POLICY "Tenants - Public view" ON public.tenants 
    FOR SELECT USING (true);
-- Super Admin full access
CREATE POLICY "Tenants - Super Admin access" ON public.tenants 
    FOR ALL USING (check_is_super_admin());

-- --- PROFILES ---
-- Baseline: Everyone can see/edit themselves (NO recursion possible)
CREATE POLICY "Profiles - Self access" ON public.profiles 
    FOR ALL USING (auth.uid() = id);

-- Sign-up: Allow inserting own record
CREATE POLICY "Profiles - Self insert" ON public.profiles 
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Team visibility: See others in same branch
-- Note: 'auth.uid() != id' ensures this policy doesn't check itself for own row
CREATE POLICY "Profiles - Team visibility" ON public.profiles 
    FOR SELECT USING (
        auth.uid() != id 
        AND tenant_id = get_current_tenant_id()
    );

-- Super Admin: Global access
CREATE POLICY "Profiles - Super Admin access" ON public.profiles 
    FOR ALL USING (
        auth.uid() != id 
        AND check_is_super_admin()
    );

-- --- OPERATIONAL TABLES (Isolation) ---
-- Standard isolation + Super Admin bypass
CREATE POLICY "Bookings - Isolation" ON public.bookings FOR ALL USING (tenant_id = get_current_tenant_id() OR check_is_super_admin());
CREATE POLICY "Inventory - Isolation" ON public.inventory FOR ALL USING (tenant_id = get_current_tenant_id() OR check_is_super_admin());
CREATE POLICY "Status - Isolation" ON public.status FOR ALL USING (tenant_id = get_current_tenant_id() OR check_is_super_admin());

DO $$ 
BEGIN 
    RAISE NOTICE '✅ RLS Master Fix v2 applied successfully.';
END $$;
