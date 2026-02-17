-- Migration: Create Direct Registration RPC v2
-- Purpose: Bypass Supabase Auth API rate limits (429) reliably
-- Security: Uses SECURITY DEFINER to write to auth schema

CREATE OR REPLACE FUNCTION public.register_user_bypass_v2(
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
    -- 1. Generate virtual email
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    
    -- 2. Check existence
    IF EXISTS (SELECT 1 FROM auth.users WHERE email = v_email) THEN
        RETURN jsonb_build_object('success', false, 'error', 'This phone number is already registered.');
    END IF;

    -- 3. Encrypt password ('ds_auth_' + pin)
    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf'));

    -- 4. Create User ID
    v_user_id := gen_random_uuid();

    -- 5. Insert into auth.users (Master Auth Table)
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, created_at, updated_at, confirmation_token, 
        raw_app_meta_data, raw_user_meta_data, is_super_admin
    ) VALUES (
        v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
        v_email, v_encrypted_pw, NOW(), NOW(), NOW(), '', 
        '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false
    );

    -- 6. Insert into auth.identities (Required for session establishment)
    -- We let Supabase generate the identity ID to avoid potential constraints
    INSERT INTO auth.identities (
        user_id, provider_id, identity_data, provider, 
        last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_user_id, v_email, jsonb_build_object('sub', v_user_id::text, 'email', v_email), 
        'email', NOW(), NOW(), NOW()
    );

    -- 7. Insert into public.profiles
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

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v2 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v2 TO authenticated;
