-- ============================================
-- RESTORE TEST USERS - MULTI-ACCOUNT SUPPORT
-- ============================================
-- Purpose: Re-seed test users after a database reset
-- Use: Run this in your Supabase SQL Editor
-- ============================================

-- 1. Ensure the Main Branch exists
INSERT INTO tenants (id, name)
VALUES ('00000000-0000-0000-0000-000000000001', 'Main Branch - Bole')
ON CONFLICT (id) DO NOTHING;

-- 2. Define the Restoration Function
-- This function handles creating/updating profiles for existing auth.users
CREATE OR REPLACE FUNCTION restore_test_profile(p_email TEXT, p_phone TEXT, p_name TEXT, p_role TEXT, p_pin TEXT)
RETURNS void AS $$
DECLARE
    target_user_id UUID;
BEGIN
    SELECT id INTO target_user_id FROM auth.users WHERE email = p_email LIMIT 1;

    IF target_user_id IS NOT NULL THEN
        INSERT INTO profiles (id, tenant_id, "phoneNumber", "displayName", "role", "pin")
        VALUES (
            target_user_id, 
            '00000000-0000-0000-0000-000000000001', 
            p_phone, 
            p_name, 
            p_role, 
            p_pin
        )
        ON CONFLICT (id) DO UPDATE SET
            tenant_id = EXCLUDED.tenant_id,
            "phoneNumber" = EXCLUDED."phoneNumber",
            "role" = EXCLUDED."role",
            "pin" = EXCLUDED."pin";
            
        RAISE NOTICE 'SUCCESS: Profile restored for user % (%)', p_name, target_user_id;
    ELSE
        RAISE NOTICE 'WARNING: User % not found in auth.users. Please create them in Supabase Dashboard first.', p_email;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Execute restoration for known test accounts
-- Password for all MUST be: ds_auth_0000 (if PIN is 0000) or ds_auth_1111 (if PIN is 1111)
SELECT restore_test_profile('251911223300@drshine.app', '+251911223300', 'Admin Manager', 'admin', '0000');
SELECT restore_test_profile('251911223344@drshine.app', '+251911223344', 'Super Admin', 'superadmin', '1111');

-- 4. Cleanup helper function
DROP FUNCTION restore_test_profile(TEXT, TEXT, TEXT, TEXT, TEXT);

DO $$ 
BEGIN 
    RAISE NOTICE 'Project test accounts preparation complete.';
    RAISE NOTICE 'IMPORTANT: Ensure passwords in Supabase Auth match the ds_auth_$pin format.';
END $$;
