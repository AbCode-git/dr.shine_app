-- ============================================
-- AUTH REPAIR V8 - THE "ATOMIC" FIX
-- ============================================
-- Populates all 35 columns identified in the inspection.
-- Fixes: "converting NULL to string is unsupported"
-- ============================================

CREATE OR REPLACE FUNCTION public.register_user_bypass_v8(
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
    -- 1. Setup Data
    v_email := regexp_replace(p_phone, '[^0-9]', '', 'g') || '@drshine.app';
    v_encrypted_pw := crypt('ds_auth_' || p_pin, gen_salt('bf', 10));
    
    -- 2. Force Clean Start
    DELETE FROM auth.users WHERE email = v_email;

    -- 3. THE ATOMIC INSERT (All 35 Columns)
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password, 
        email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data,
        is_super_admin, created_at, updated_at, phone, phone_confirmed_at,
        phone_change, phone_change_token, phone_change_sent_at, confirmed_at,
        email_change_token_current, email_change_confirm_status, banned_until,
        reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at,
        is_anonymous
    ) VALUES (
        '00000000-0000-0000-0000-000000000000', -- instance_id
        v_user_id,                             -- id
        'authenticated',                       -- aud
        'authenticated',                       -- role
        v_email,                               -- email
        v_encrypted_pw,                        -- encrypted_password
        NOW(),                                 -- email_confirmed_at
        NULL,                                  -- invited_at
        '',                                    -- confirmation_token (FIXED)
        NULL,                                  -- confirmation_sent_at
        '',                                    -- recovery_token (FIXED)
        NULL,                                  -- recovery_sent_at
        '',                                    -- email_change_token_new (FIXED)
        '',                                    -- email_change (FIXED - Index 8 error)
        NULL,                                  -- email_change_sent_at
        NOW(),                                 -- last_sign_in_at
        '{"provider":"email","providers":["email"]}'::jsonb, -- raw_app_meta_data
        '{}'::jsonb,                           -- raw_user_meta_data
        false,                                 -- is_super_admin
        NOW(),                                 -- created_at
        NOW(),                                 -- updated_at
        p_phone,                               -- phone
        NOW(),                                 -- phone_confirmed_at
        '',                                    -- phone_change (FIXED)
        '',                                    -- phone_change_token (FIXED)
        NULL,                                  -- phone_change_sent_at
        NOW(),                                 -- confirmed_at
        '',                                    -- email_change_token_current (FIXED)
        0,                                     -- email_change_confirm_status
        NULL,                                  -- banned_until
        '',                                    -- reauthentication_token (FIXED)
        NULL,                                  -- reauthentication_sent_at
        false,                                 -- is_sso_user
        NULL,                                  -- deleted_at
        false                                  -- is_anonymous
    );

    -- 4. Create Identity
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, 
        last_sign_in_at, created_at, updated_at
    ) VALUES (
        gen_random_uuid(), v_user_id,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
        'email', v_email, NOW(), NOW(), NOW()
    );

    -- 5. Insert Profile
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

GRANT EXECUTE ON FUNCTION public.register_user_bypass_v8 TO anon;
GRANT EXECUTE ON FUNCTION public.register_user_bypass_v8 TO authenticated;

DO $$ 
BEGIN 
    RAISE NOTICE '⚡ ATOMIC FIX APPLIED. All 35 columns shielded.';
END $$;
