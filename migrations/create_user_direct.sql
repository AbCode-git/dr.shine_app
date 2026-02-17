-- ============================================
-- DIRECT USER CREATION (Bypasses Supabase Rate Limits)
-- ============================================
-- Run this in Supabase SQL Editor to create users directly.
-- This avoids the 429 "Too Many Requests" error from the signUp API.
-- ============================================

-- USAGE: Update these variables for each new user
-- Phone:  +251910627651
-- Name:   Abrilo
-- Role:   admin
-- PIN:    0000  (change as needed)
-- Branch: Use the tenant_id from your tenants table

DO $$
DECLARE
  v_user_id UUID;
  v_email TEXT;
  v_encrypted_pw TEXT;
  v_tenant_id UUID;

  -- ████ EDIT THESE VALUES ████
  v_phone TEXT := '+251910627651';
  v_name TEXT := 'Abrilo';
  v_role TEXT := 'admin';
  v_pin TEXT := '0000';
BEGIN
  -- Derive the virtual email and password (must match app logic)
  v_email := regexp_replace(v_phone, '[^0-9]', '', 'g') || '@drshine.app';
  v_encrypted_pw := crypt('ds_auth_' || v_pin, gen_salt('bf'));

  -- Get the first available tenant (branch)
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;

  -- Generate a new UUID for the user
  v_user_id := gen_random_uuid();

  -- Step 1: Insert into auth.users (Supabase Auth table)
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    raw_app_meta_data,
    raw_user_meta_data
  ) VALUES (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    v_email,
    v_encrypted_pw,
    NOW(),       -- Mark email as confirmed (skip verification)
    NOW(),
    NOW(),
    '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb
  )
  ON CONFLICT (email) DO UPDATE SET
    encrypted_password = EXCLUDED.encrypted_password,
    updated_at = NOW();

  -- Get the actual user ID (in case of conflict/update)
  SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;

  -- Step 2: Ensure identity record exists
  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_user_id,
    v_email,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email',
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (provider_id, provider) DO NOTHING;

  -- Step 3: Create the profile row
  INSERT INTO profiles (id, tenant_id, "phoneNumber", "displayName", "role", "pin")
  VALUES (v_user_id, v_tenant_id, v_phone, v_name, v_role, v_pin)
  ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    "displayName" = EXCLUDED."displayName",
    "role" = EXCLUDED."role",
    "pin" = EXCLUDED."pin";

  RAISE NOTICE '✅ User created successfully!';
  RAISE NOTICE '   ID:    %', v_user_id;
  RAISE NOTICE '   Email: %', v_email;
  RAISE NOTICE '   Phone: %', v_phone;
  RAISE NOTICE '   Name:  %', v_name;
  RAISE NOTICE '   Role:  %', v_role;
  RAISE NOTICE '   PIN:   %', v_pin;
  RAISE NOTICE '   Login: Use phone=% and PIN=% in the app', v_phone, v_pin;
END $$;
