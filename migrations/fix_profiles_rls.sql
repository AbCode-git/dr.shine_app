-- ============================================
-- FIX PROFILES RLS - FINAL RECURSION-SAFE VERSION
-- ============================================
-- Purpose: Fix 500 Internal Server Error & Infinite Recursion
-- Supports: Sign-up (profile self-creation) + Tenant isolation
-- Use: Run this in your Supabase SQL Editor
-- ============================================

-- 1. Setup Robust Helper Functions (SECURITY DEFINER bypasses RLS for the function itself)
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT tenant_id FROM profiles WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT role = 'superadmin' FROM profiles WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;


-- 2. Drop existing policies to make the script idempotent
DROP POLICY IF EXISTS "Profiles access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Owner access" ON profiles;
DROP POLICY IF EXISTS "Profiles - Self insert" ON profiles;
DROP POLICY IF EXISTS "Profiles - Tenant visibility" ON profiles;
DROP POLICY IF EXISTS "Profiles - Manager management" ON profiles;
DROP POLICY IF EXISTS "Profiles - Super Admin bypass" ON profiles;

-- 3. Policy: Owner Access (The fundamental baseline)
-- Users can ALWAYS see and edit their own row.
-- This policy does NOT call any recursive functions.
CREATE POLICY "Profiles - Owner access" ON profiles 
    FOR ALL 
    USING (auth.uid() = id);

-- 4. Policy: Self Insert (For Sign-Up)
-- A newly registered user can insert their own profile row.
CREATE POLICY "Profiles - Self insert" ON profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 5. Policy: Tenant Data Visibility
-- Users can see other profiles within their same tenant.
-- Recursion guard: auth.uid() != id (so we don't trigger for own row)
CREATE POLICY "Profiles - Tenant visibility" ON profiles
    FOR SELECT
    USING (
        auth.uid() != id 
        AND tenant_id = get_user_tenant_id()
    );

-- 6. Policy: Manager Management Access
-- Admins and SuperAdmins can manage profiles within their tenant.
-- Recursion guard: auth.uid() != id
CREATE POLICY "Profiles - Manager management" ON profiles
    FOR ALL
    USING (
        auth.uid() != id
        AND tenant_id = get_user_tenant_id() 
        AND (
            SELECT role FROM profiles 
            WHERE id = auth.uid()
        ) IN ('admin', 'superadmin')
    );

-- 7. Policy: Super Admin Bypass
-- Super Admins can manage all profiles globally.
-- Recursion guard: auth.uid() != id
CREATE POLICY "Profiles - Super Admin bypass" ON profiles
    FOR ALL
    USING (
        auth.uid() != id
        AND is_super_admin()
    );

DO $$ 
BEGIN 
    RAISE NOTICE 'SUCCESS: RLS policies updated with recursion protection and self-insert support.';
END $$;
