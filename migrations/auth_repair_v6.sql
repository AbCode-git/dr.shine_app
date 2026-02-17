-- ============================================
-- AUTH REPAIR V6 - THE "NULL SCAN" FIX
-- ============================================
-- This fixes the specific error: 
-- "converting NULL to string is unsupported" for column "email_change"
-- ============================================

CREATE OR REPLACE FUNCTION public.register_user_bypass_v6(
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
    -- 1. Generate virtual email
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    
    -- 2. Check if user exists
    IF EXISTS (SELECT 1 FROM auth.users WHERE email = v_email) THEN
        RETURN jsonb_build_object('success', false, 'error', 'User already exists');
    END IF;

    -- 3. Encrypt password (bcrypt 10 rounds)
    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf', 10));

    -- 4. Create User with NO NULL STRINGS (Fixes Go Scan Error)
    INSERT INTO auth.users (
        id, 
        instance_id, 
        aud, 
        role, 
        email, 
        encrypted_password, 
        email_confirmed_at, 
        last_sign_in_at, 
        created_at, 
        updated_at,
        raw_app_meta_data, 
        raw_user_meta_data, 
        is_super_admin, 
        is_sso_user,
        phone, 
        phone_confirmed_at, 
        confirmation_token,
        -- CRITICAL: Initialize string columns to empty, NOT NULL
        email_change,
        email_change_token_new,
        email_change_token_current,
        recovery_token,
        reauthentication_token
    ) VALUES (
        v_user_id, 
        '00000000-0000-0000-0000-000000000000', 
        'authenticated', 
        'authenticated', 
        v_email, 
        v_encrypted_pw, 
        NOW(), 
        NOW(), 
        NOW(), 
        NOW(),
        '{"provider": "email", "providers": ["email"]}'::jsonb, 
        '{}'::jsonb, 
        false, 
        false,
        p_phone, 
        NOW(), 
        '', -- confirmation_token
        '', -- email_change
        '', -- email_change_token_new
        '', -- email_change_token_current
        '', -- recovery_token
        ''  -- reauthentication_token
    );

    -- 5. Link Identity
    INSERT INTO auth.identities (
        id, 
        user_id, 
        identity_data, 
        provider, 
        provider_id, 
        last_sign_in_at, 
        created_at, 
        updated_at
    ) VALUES (
        gen_random_uuid(), 
        v_user_id,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
        'email', 
        v_email, 
        NOW(), 
        NOW(), 
        NOW()
    );

    -- 6. Insert Profile
    INSERT INTO public.profiles (
        id, 
        tenant_id, 
        "phoneNumber", 
        "displayName", 
        "role", 
        "pin"
    ) VALUES (
        v_user_id, 
        p_tenant_id, 
        p_phone, 
        p_display_name, 
        p_role, 
        p_pin
    );

    RETURN jsonb_build_object('success', true, 'user_id', v_user_id);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v6 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v6 TO authenticated;
