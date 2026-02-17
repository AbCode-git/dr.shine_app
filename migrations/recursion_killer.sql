-- ============================================
-- THE FINAL NUCLEAR FIX - RECURSION KILLER
-- ============================================
-- 1. Disables all triggers that query profiles
-- 2. Drops all recursive policies
-- 3. Re-enables safe policies
-- ============================================

-- A. DROP TRIGGERS FIRST (They are often the hidden 500 cause)
DROP TRIGGER IF EXISTS bookings_set_tenant ON bookings;
DROP TRIGGER IF EXISTS inventory_set_tenant ON inventory;
DROP TRIGGER IF EXISTS status_set_tenant ON status;

-- B. DROP PROBLEM FUNCTIONS
DROP FUNCTION IF EXISTS set_tenant_id() CASCADE;

-- C. DROP ALL POLICIES (Nuclear Cleanup)
DO $$ 
DECLARE 
    pol record;
BEGIN 
    FOR pol IN SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- D. RECREATE SAFE HELPER (Must be SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, auth;

-- E. RECREATE MINIMAL SAFE POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_self_access" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "profiles_team_access" ON public.profiles FOR SELECT USING (tenant_id = get_user_tenant_id());
CREATE POLICY "tenants_public_read" ON public.tenants FOR SELECT USING (true);

-- F. CLEAN TEST DATA
DELETE FROM auth.users WHERE email LIKE '%@drshine.app';

DO $$ 
BEGIN 
    RAISE NOTICE '🛑 ALL RECURSION HAS BEEN STOPPED. Profiles are safe.';
END $$;
