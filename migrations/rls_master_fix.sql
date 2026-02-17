-- ============================================
-- MASTER RLS FIX - RESOLVES 500 INTERNAL ERROR
-- ============================================
-- Cleanly replaces all recursive policies with safe versions.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- 1. Setup Safe Helper Functions (SECURITY DEFINER bypasses RLS)
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT role = 'superadmin' FROM public.profiles WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

-- 2. Clean up ALL existing policies for these tables
DROP POLICY IF EXISTS "Profiles access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Owner access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Self insert" ON profiles;
DROP POLICY IF EXISTS "Profiles - Tenant visibility" ON profiles;
DROP POLICY IF EXISTS "Profiles - Manager management" ON profiles;
DROP POLICY IF EXISTS "Profiles - Super Admin bypass" ON profiles;

DROP POLICY IF EXISTS "Users can view their tenant" ON tenants;
DROP POLICY IF EXISTS "Public can view branch names" ON tenants;
DROP POLICY IF EXISTS "Super admins can view all tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can create tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can delete tenants" ON tenants;

DROP POLICY IF EXISTS "Tenant isolation for bookings" ON bookings;
DROP POLICY IF EXISTS "Tenant isolation for inventory" ON inventory;
DROP POLICY IF EXISTS "Tenant isolation for status" ON status;

-- 3. RECREATE SAFE POLICIES

-- --- TENANTS ---
-- Public can see names for sign-up picker
CREATE POLICY "Tenants - Public view" ON tenants FOR SELECT USING (true);
-- Super admins can do anything
CREATE POLICY "Tenants - Super Admin access" ON tenants FOR ALL USING (is_super_admin());

-- --- PROFILES ---
-- Fundamental: Users can see/edit themselves (No recursion)
CREATE POLICY "Profiles - Self access" ON profiles FOR ALL USING (auth.uid() = id);
-- Sign-up: Users can create their own row
CREATE POLICY "Profiles - Self insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
-- Team visibility: See others in same branch
CREATE POLICY "Profiles - Team visibility" ON profiles FOR SELECT USING (tenant_id = get_user_tenant_id());
-- Super Admin: Global access
CREATE POLICY "Profiles - Super Admin bypass" ON profiles FOR ALL USING (is_super_admin());

-- --- OPERATIONAL TABLES ---
CREATE POLICY "Bookings - Tenant isolation" ON bookings FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());
CREATE POLICY "Inventory - Tenant isolation" ON inventory FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());
CREATE POLICY "Status - Tenant isolation" ON status FOR ALL USING (tenant_id = get_user_tenant_id() OR is_super_admin());

-- 4. Verify Search Path for RPC (Optional but recommended)
-- Ensure 'extensions' is in the bypass function if you used it
-- (Already handled in the latest register_user_rpc.sql)

DO $$ 
BEGIN 
    RAISE NOTICE '✅ RLS Master Fix complete! 500 errors should be resolved.';
END $$;
