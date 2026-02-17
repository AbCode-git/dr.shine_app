-- ============================================
-- SEED TEST DATA - Dr. Shine Car Wash
-- ============================================
-- Purpose: Create test tenant and users for development
-- Safe to run multiple times (uses INSERT ON CONFLICT)
-- ============================================

-- ============================================
-- 1. Create Test Tenant (Main Branch)
-- ============================================
INSERT INTO tenants (id, name, created_at)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Main Branch - Bole',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name;

-- ============================================
-- 2. Create Test Users in Supabase Auth
-- ============================================
-- Note: These need to be created via Supabase Dashboard or API
-- Below are the credentials for manual creation

/*
SUPER ADMIN:
- Phone: +251911234567
- Virtual Email: +251911234567@drshine.app
- PIN: 1111
- Role: superadmin
- Tenant: Main Branch - Bole

MANAGER:
- Phone: +251922345678
- Virtual Email: +251922345678@drshine.app
- PIN: 2222
- Role: admin
- Tenant: Main Branch - Bole

STAFF:
- Phone: +251933456789
- Virtual Email: +251933456789@drshine.app
- PIN: 3333
- Role: staff
- Tenant: Main Branch - Bole
*/

-- ============================================
-- 3. Create Profiles for Test Users
-- ============================================
-- NOTE: Replace the UUIDs below with actual user IDs from Supabase Auth
-- You can get these from: Supabase Dashboard > Authentication > Users

-- Example profiles (UPDATE THE IDs AFTER CREATING AUTH USERS):
/*
INSERT INTO profiles (id, tenant_id, "phoneNumber", "displayName", "role", "pin", "createdAt")
VALUES 
    (
        'REPLACE-WITH-SUPERADMIN-UUID',
        '00000000-0000-0000-0000-000000000001',
        '+251911234567',
        'Super Admin User',
        'superadmin',
        '1111',
        NOW()
    ),
    (
        'REPLACE-WITH-MANAGER-UUID',
        '00000000-0000-0000-0000-000000000001',
        '+251922345678',
        'Manager User',
        'admin',
        '2222',
        NOW()
    ),
    (
        'REPLACE-WITH-STAFF-UUID',
        '00000000-0000-0000-0000-000000000001',
        '+251933456789',
        'Staff User',
        'staff',
        '3333',
        NOW()
    )
ON CONFLICT (id) DO UPDATE SET
    "displayName" = EXCLUDED."displayName",
    "role" = EXCLUDED."role",
    "pin" = EXCLUDED."pin";
*/

-- ============================================
-- 4. Seed Sample Services (Optional)
-- ============================================
-- This data would typically be in a services table
-- For now, services are hardcoded in the app

-- ============================================
-- 5. Seed Sample Inventory (Optional)
-- ============================================
/*
INSERT INTO inventory (tenant_id, "name", "category", "currentStock", "minStockLevel", "unit", "costPerUnit")
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'Car Shampoo Premium', 'carWash', 50, 10, 'liters', 25.50),
    ('00000000-0000-0000-0000-000000000001', 'Tire Shine', 'carWash', 30, 15, 'liters', 18.00),
    ('00000000-0000-0000-0000-000000000001', 'Engine Oil 5W-30', 'oilChange', 40, 20, 'liters', 85.00)
ON CONFLICT DO NOTHING;
*/

-- ============================================
-- MANUAL STEPS REQUIRED
-- ============================================

/*
To complete the test setup:

1. Go to Supabase Dashboard > Authentication > Add User
2. Create users with these virtual emails AND passwords:
   - Email: +251911234567@drshine.app | Password: 1111
   - Email: +251922345678@drshine.app | Password: 2222
   - Email: +251933456789@drshine.app | Password: 3333

Note: The password in Supabase Auth should be the same as the 4-digit PIN.

3. Copy their UUIDs and update the profiles INSERT above
4. Run the updated INSERT statements

5. Test in the app:
   - Phone: +251911234567 → PIN: 1111 (Super Admin)
   - Phone: +251922345678 → PIN: 2222 (Manager)
   - Phone: +251933456789 → PIN: 3333 (Staff)
*/
