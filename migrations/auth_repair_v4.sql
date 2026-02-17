-- ============================================
-- AUTH SCHEMA DIAGNOSTICS & REPAIR
-- ============================================
-- Run this in your Supabase SQL Editor.
-- This will help us find exactly why the login is failing with 500.
-- ============================================

-- 1. Wipe failed test users
DELETE FROM auth.users WHERE email LIKE '%@drshine.app';

-- 2. Create an "Ultra-Standard" Registration RPC (v4)
-- This version uses ONLY the columns known to be safe and mandatory.
CREATE OR REPLACE FUNCTION public.register_user_bypass_v4(
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
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf'));

    -- A. INSERT INTO auth.users
    -- We use the most minimal set of columns possible.
    INSERT INTO auth.users (
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        is_sso_user
    ) VALUES (
        v_user_id,
        'authenticated',
        'authenticated',
        v_email,
        v_encrypted_pw,
        NOW(),
        NOW(),
        '{"provider": "email", "providers": ["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(),
        NOW(),
        '',
        false
    );

    -- B. INSERT INTO auth.identities
    -- This links the email to the user so GoTrue can find it.
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
        v_user_id, -- Using same UUID for identity ID is standard in early Supabase
        v_user_id,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
        'email',
        v_email,
        NOW(),
        NOW(),
        NOW()
    );

    -- C. INSERT INTO public.profiles
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

    RETURN jsonb_build_object('success', true, 'user_id', v_user_id, 'email', v_email);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v4 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v4 TO authenticated;

-- 3. Diagnostic Query: If login still fails, run this and tell me the results:
-- SELECT * FROM auth.users WHERE email LIKE '%@drshine.app';
-- SELECT * FROM auth.identities WHERE user_id IN (SELECT id FROM auth.users WHERE email LIKE '%@drshine.app');
