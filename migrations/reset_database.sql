-- ============================================
-- RESET DATABASE - DESTRUCTIVE OPERATION
-- ============================================
-- WARNING: This will DELETE ALL DATA and recreate tables
-- Date: 2026-02-17
-- Purpose: Clean slate with latest multi-tenant schema
-- ============================================

-- ============================================
-- STEP 1: Drop All Policies
-- ============================================
DROP POLICY IF EXISTS "Users can view their tenant" ON tenants;
DROP POLICY IF EXISTS "Super admins can view all tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can create tenants" ON tenants;
DROP POLICY IF EXISTS "Super admins can delete tenants" ON tenants;
DROP POLICY IF EXISTS "Profiles access" ON profiles;
DROP POLICY IF EXISTS "Tenant isolation for bookings" ON bookings;
DROP POLICY IF EXISTS "Tenant isolation for inventory" ON inventory;
DROP POLICY IF EXISTS "Tenant isolation for status" ON status;

-- ============================================
-- STEP 2: Drop All Triggers
-- ============================================
DROP TRIGGER IF EXISTS bookings_set_tenant ON bookings;
DROP TRIGGER IF EXISTS inventory_set_tenant ON inventory;
DROP TRIGGER IF EXISTS status_set_tenant ON status;

-- ============================================
-- STEP 3: Drop All Functions
-- ============================================
DROP FUNCTION IF EXISTS get_user_tenant_id();
DROP FUNCTION IF EXISTS is_super_admin();
DROP FUNCTION IF EXISTS set_tenant_id();

-- ============================================
-- STEP 4: Drop All Tables (in correct order)
-- ============================================
-- Drop tables with foreign keys first
DROP TABLE IF EXISTS status;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS tenants;

-- ============================================
-- STEP 5: Recreate Tables
-- ============================================

-- 1. Create Tenants Table (for multi-tenancy)
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Profiles Table (extends Supabase Auth)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    tenant_id UUID REFERENCES tenants(id),
    "phoneNumber" TEXT UNIQUE,
    "displayName" TEXT,
    "role" TEXT DEFAULT 'staff',
    "pin" TEXT,
    "loyaltyPoints" INTEGER DEFAULT 0,
    "isOnDuty" BOOLEAN DEFAULT false,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Bookings Table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id),
    "userId" TEXT, 
    "vehicleId" TEXT,
    "serviceId" TEXT NOT NULL,
    "status" TEXT DEFAULT 'pending',
    "bookingDate" TIMESTAMPTZ NOT NULL,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "price" DECIMAL(10, 2) NOT NULL,
    "mileage" DECIMAL,
    "customerPhone" TEXT,
    "carBrand" TEXT,
    "carModel" TEXT,
    "plateNumber" TEXT,
    "washerStaffId" UUID REFERENCES auth.users(id),
    "washerStaffName" TEXT,
    "completedAt" TIMESTAMPTZ
);

-- 4. Create Inventory Table
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id),
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "currentStock" DECIMAL DEFAULT 0,
    "minStockLevel" DECIMAL DEFAULT 10,
    "reorderLevel" DECIMAL DEFAULT 20,
    "unit" TEXT DEFAULT 'liters',
    "costPerUnit" DECIMAL DEFAULT 0,
    "lastRestocked" TIMESTAMPTZ,
    "supplier" TEXT,
    "viscosityGrade" TEXT,
    "brand" TEXT
);

-- 5. Create Status Table
CREATE TABLE status (
    id TEXT PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    "status" TEXT NOT NULL,
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- STEP 6: Enable Row Level Security
-- ============================================
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE status ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 7: Create Helper Functions
-- ============================================

-- Function: Get current user's tenant_id
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Function: Check if user is Super Admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'superadmin' FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Function: Auto-set tenant_id for new records
CREATE OR REPLACE FUNCTION set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 8: Create RLS Policies for Tenants
-- ============================================

-- Policy: All users can view their assigned tenant
CREATE POLICY "Users can view their tenant" ON tenants
    FOR SELECT
    USING (id = get_user_tenant_id());

-- Policy: Super Admins can view all tenants
CREATE POLICY "Super admins can view all tenants" ON tenants
    FOR SELECT
    USING (is_super_admin());

-- Policy: Super Admins can create new branches
CREATE POLICY "Super admins can create tenants" ON tenants
    FOR INSERT
    WITH CHECK (is_super_admin());

-- Policy: Super Admins can delete branches
CREATE POLICY "Super admins can delete tenants" ON tenants
    FOR DELETE
    USING (is_super_admin());

-- ============================================
-- STEP 9: Create RLS Policies for Operational Tables
-- ============================================

-- Profiles: Users can see their own profile OR profiles in their own tenant
CREATE POLICY "Profiles access" ON profiles
    FOR ALL USING (
        id = auth.uid() 
        OR 
        tenant_id = (SELECT tenant_id FROM profiles WHERE id = auth.uid())
    );

-- Bookings: Users can see/modify bookings in their own tenant
CREATE POLICY "Tenant isolation for bookings" ON bookings
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- Inventory: Users can see/modify inventory in their own tenant
CREATE POLICY "Tenant isolation for inventory" ON inventory
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- Status: Users can see/modify status in their own tenant
CREATE POLICY "Tenant isolation for status" ON status
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- ============================================
-- STEP 10: Create Triggers for Auto-Tenant Assignment
-- ============================================

CREATE TRIGGER bookings_set_tenant BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER inventory_set_tenant BEFORE INSERT ON inventory
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER status_set_tenant BEFORE INSERT ON status
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

-- ============================================
-- STEP 11: Seed Default Tenant (Optional)
-- ============================================

-- Uncomment to create a default tenant for testing
-- INSERT INTO tenants (id, name) VALUES 
--   ('00000000-0000-0000-0000-000000000001', 'Main Branch - Ayat');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check all tables exist
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- Check RLS is enabled on all tables
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- Check policies count
-- SELECT tablename, COUNT(*) as policy_count FROM pg_policies WHERE schemaname = 'public' GROUP BY tablename;

-- ============================================
-- RESET COMPLETE
-- ============================================
