-- ============================================
-- AUTH REPAIR V7 - THE "ULTIMATE NULL SHIELD"
-- ============================================
-- This script fixes the "converting NULL to string" crash.
-- It initializes EVERY possible string column to avoid Go Scan errors.
-- ============================================

-- 1. GLOCAL FIX for existing users (Cleans up previous failed attempts)
UPDATE auth.users 
SET 
    confirmation_token = COALESCE(confirmation_token, ''),
    recovery_token = COALESCE(recovery_token, ''),
    email_change_token_new = COALESCE(email_change_token_new, ''),
    email_change = COALESCE(email_change, ''),
    phone_change = COALESCE(phone_change, ''),
    phone_change_token = COALESCE(phone_change_token, ''),
    email_change_token_current = COALESCE(email_change_token_current, ''),
    reauthentication_token = COALESCE(reauthentication_token, ''),
    phone = COALESCE(phone, '')
WHERE email LIKE '%@drshine.app';

-- 2. THE IMPROVED bypass function (v7)
CREATE OR REPLACE FUNCTION public.register_user_bypass_v7(
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
    v_user_id UUID := gen_random_uuid();
    v_email TEXT;
    v_encrypted_pw TEXT;
BEGIN
    -- A. Define virtual email
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    
    -- B. DELETE existing user if they exist (Force Refresh)
    DELETE FROM auth.users WHERE email = v_email;

    -- C. Encrypt password (bcrypt 10 rounds)
    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf', 10));

    -- D. Insert User with ZERO NULL STRINGS
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, last_sign_in_at, created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data, is_super_admin, is_sso_user,
        phone, phone_confirmed_at, 
        -- ALL STRING COLUMNS MUST BE EMPTY, NOT NULL
        confirmation_token,
        recovery_token,
        email_change_token_new,
        email_change,
        phone_change,
        phone_change_token,
        email_change_token_current,
        reauthentication_token
    ) VALUES (
        v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
        v_email, v_encrypted_pw, NOW(), NOW(), NOW(), NOW(),
        '{"provider": "email", "providers": ["email"]}'::jsonb, '{}'::jsonb, false, false,
        p_phone, NOW(),
        '', -- confirmation_token
        '', -- recovery_token
        '', -- email_change_token_new
        '', -- email_change
        '', -- phone_change
        '', -- phone_change_token
        '', -- email_change_token_current
        ''  -- reauthentication_token
    );

    -- E. Link Identity
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, 
        last_sign_in_at, created_at, updated_at
    ) VALUES (
        gen_random_uuid(), v_user_id,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
        'email', v_email, NOW(), NOW(), NOW()
    );

    -- F. Insert Profile
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

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v7 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v7 TO authenticated;

DO $$ 
BEGIN 
    RAISE NOTICE '🚀 SHIELD ACTIVE. Existing records patched. RPC v7 ready.';
END $$;
