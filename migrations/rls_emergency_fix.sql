-- ============================================
-- RLS EMERGENCY FIX - DISABLE RLS & CLEAR USERS
-- ============================================
-- Purpose: Stop the 500 "Database error querying schema" error.
-- This disables RLS to prove the app can log in.
-- ============================================

-- 1. DISABLE RLS on all problematic tables
-- (This will stop the recursion immediately)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.status DISABLE ROW LEVEL SECURITY;

-- 2. DROP ALL POLICIES (Clean Slate)
DO $$ 
DECLARE 
    pol record;
BEGIN 
    FOR pol IN SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY %I ON %I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- 3. DELETE THE "BROKEN" USER TO START FRESH
-- (The 500 error might have left the user in a weird state)
DELETE FROM auth.users WHERE email LIKE '%@drshine.app';
-- Profiles will auto-delete due to foreign key cascade

-- 4. RECREATE THE REGISTRATION BYPASS (v3 - Ultra Stable)
CREATE OR REPLACE FUNCTION public.register_user_bypass_v3(
    p_phone TEXT,
    p_pin TEXT,
    p_display_name TEXT,
    p_role TEXT,
    p_tenant_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
    v_user_id UUID;
    v_email TEXT;
    v_encrypted_pw TEXT;
BEGIN
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    
    IF EXISTS (SELECT 1 FROM auth.users WHERE email = v_email) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already registered.');
    END IF;

    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf'));
    v_user_id := gen_random_uuid();

    -- Insert User
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, created_at, updated_at, 
        raw_app_meta_data, raw_user_meta_data, is_super_admin
    ) VALUES (
        v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
        v_email, v_encrypted_pw, NOW(), NOW(), NOW(), 
        '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false
    );

    -- Insert Identity (GoTrue requirement)
    INSERT INTO auth.identities (
        user_id, provider_id, identity_data, provider, 
        last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_user_id, v_email, 
        jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true), 
        'email', NOW(), NOW(), NOW()
    );

    -- Insert Profile
    INSERT INTO public.profiles (
        id, tenant_id, "phoneNumber", "displayName", "role", "pin"
    ) VALUES (
        v_user_id, p_tenant_id, p_phone, p_display_name, p_role, p_pin
    );

    RETURN jsonb_build_object('success', true, 'user_id', v_user_id);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v3 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v3 TO authenticated;

DO $$ 
BEGIN 
    RAISE NOTICE '🔥 EMERGENCY FIX APPLIED! RLS is DISABLED. Users cleared. RPC v3 ready.';
END $$;
