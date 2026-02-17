-- Migration: Add Tenant Table RLS Security
-- Purpose: Enforce multi-tenant isolation at database level
-- Date: 2026-02-17
-- Safe to run multiple times (idempotent)

-- ============================================
-- Step 1: Enable RLS on Tenants Table
-- ============================================
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Step 2: Create Helper Functions
-- ============================================

-- Function: Check if current user is Super Admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'superadmin' FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================
-- Step 3: Drop Existing Policies (if any)
-- ============================================
DROP POLICY IF EXISTS "Public can view branch names" ON tenants;
DROP POLICY IF EXISTS "Users can view their tenant" ON tenants;
DROP POLICY IF EXISTS "Super admins can view all tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can create tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can delete tenants" ON tenants;

-- ============================================
-- Step 4: Create Tenant Access Policies
-- ============================================

-- Policy 0: Public can view branch names (needed for sign-up branch picker)
CREATE POLICY "Public can view branch names" ON tenants
    FOR SELECT
    USING (true);

-- Policy 1: All users can view their assigned tenant
CREATE POLICY "Users can view their tenant" ON tenants
    FOR SELECT
    USING (id = get_user_tenant_id());

-- Policy 2: Super Admins can view all tenants
CREATE POLICY "Super admins can view all tenants" ON tenants
    FOR SELECT
    USING (is_super_admin());

-- Policy 3: Super Admins can create new branches
CREATE POLICY "Super admins can create tenants" ON tenants
    FOR INSERT
    WITH CHECK (is_super_admin());

-- Policy 4: Super Admins can delete branches
CREATE POLICY "Super admins can delete tenants" ON tenants
    FOR DELETE
    USING (is_super_admin());

-- ============================================
-- Step 5: Auto-Tenant Triggers (Optional)
-- ============================================

-- Function: Automatically set tenant_id from user's profile
CREATE OR REPLACE FUNCTION set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing triggers (if any)
DROP TRIGGER IF EXISTS bookings_set_tenant ON bookings;
DROP TRIGGER IF EXISTS inventory_set_tenant ON inventory;
DROP TRIGGER IF EXISTS status_set_tenant ON status;

-- Create triggers for auto-tenant assignment
CREATE TRIGGER bookings_set_tenant BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER inventory_set_tenant BEFORE INSERT ON inventory
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER status_set_tenant BEFORE INSERT ON status
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

-- ============================================
-- Verification Query (Run after migration)
-- ============================================

-- Check that RLS is enabled
-- Expected: tenants table should show rls_enabled = true
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'tenants';

-- Check policies exist
-- Expected: 4 policies on tenants table
-- SELECT * FROM pg_policies WHERE tablename = 'tenants';
