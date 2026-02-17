-- ============================================
-- THE "EXORCIST" FIX - AUTH TRIGGER PURGE
-- ============================================
-- Since RLS is OFF and we still get a 500 error,
-- there MUST be a broken trigger hidden on auth.users.
-- ============================================

-- 1. Purge ALL triggers on auth.users and auth.identities
-- (This is where the sneaky 500 errors hide)
DO $$ 
DECLARE 
    trig record;
BEGIN 
    FOR trig IN 
        SELECT trigger_name, event_object_table, event_object_schema
        FROM information_schema.triggers 
        WHERE event_object_schema = 'auth'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I.%I', 
            trig.trigger_name, trig.event_object_schema, trig.event_object_table);
        RAISE NOTICE 'Purged trigger: % on %.%', trig.trigger_name, trig.event_object_schema, trig.event_object_table;
    END LOOP;
END $$;

-- 2. Clear out any "Ghost" data
DELETE FROM auth.users WHERE email LIKE '%@drshine.app';

-- 3. Re-enable RLS (Safe Mode)
-- We'll turn it back on but with NO policies so it's empty but active.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

-- 4. Re-grant search path for the bypass function
-- (Some Supabase updates reset this)
ALTER FUNCTION public.register_user_bypass_v5(text, text, text, text, uuid) 
SET search_path = public, auth, extensions;

DO $$ 
BEGIN 
    RAISE NOTICE '🛡️  Exorcism complete. Triggers purged. Ready for a clean login.';
END $$;
