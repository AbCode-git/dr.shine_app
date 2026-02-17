-- 1. Create Tenants Table (for multi-tenancy)
CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Profiles Table (extends Supabase Auth)
CREATE TABLE IF NOT EXISTS profiles (
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
CREATE TABLE IF NOT EXISTS bookings (
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
CREATE TABLE IF NOT EXISTS inventory (
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
CREATE TABLE IF NOT EXISTS status (
    id TEXT PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    "status" TEXT NOT NULL,
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE status ENABLE ROW LEVEL SECURITY;

-- 6. RLS Helper Function: Get current user's tenant_id
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 7. RLS Helper Function: Check if user is Super Admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT role = 'superadmin' FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 8. RLS Policies for Tenants Table

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

-- 9. RLS Policies for Operational Tables

-- Profiles: Users can see profiles in their own tenant
CREATE POLICY "Tenant isolation for profiles" ON profiles
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- Bookings: Users can see/modify bookings in their own tenant
CREATE POLICY "Tenant isolation for bookings" ON bookings
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- Inventory: Users can see/modify inventory in their own tenant
CREATE POLICY "Tenant isolation for inventory" ON inventory
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- Status: Users can see/modify status in their own tenant
CREATE POLICY "Tenant isolation for status" ON status
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- 10. Trigger: Auto-set tenant_id for new records (optional enhancement)
-- This ensures tenant_id is automatically populated from the user's profile
CREATE OR REPLACE FUNCTION set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply auto-tenant trigger to operational tables
CREATE TRIGGER bookings_set_tenant BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER inventory_set_tenant BEFORE INSERT ON inventory
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER status_set_tenant BEFORE INSERT ON status
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();
