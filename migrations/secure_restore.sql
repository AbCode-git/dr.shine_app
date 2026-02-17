-- ============================================
-- SECURE RESTORATION - RLS RE-ENABLEMENT
-- ============================================
-- Now that login is working, we add back security 
-- without the infinite loops.
-- ============================================

-- 1. RE-ENABLE RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.status ENABLE ROW LEVEL SECURITY;

-- 2. DROP OLD POLICIES
DROP POLICY IF EXISTS "profiles_self_access" ON public.profiles;
DROP POLICY IF EXISTS "profiles_team_access" ON public.profiles;
DROP POLICY IF EXISTS "tenants_public_read" ON public.tenants;

-- 3. CREATE STABLE HELPER (SECURITY DEFINER)
-- This MUST hide the lookup to prevent recursion.
CREATE OR REPLACE FUNCTION public.get_my_tenant_id()
RETURNS UUID 
LANGUAGE sql 
STABLE 
SECURITY DEFINER 
SET search_path = public
AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid();
$$;

-- 4. CREATE NEW CLEAN POLICIES

-- Profiles: 
-- A. I can see my own profile
CREATE POLICY "profiles_own" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- B. I can see colleagues in my branch (using the helper)
CREATE POLICY "profiles_branch" ON public.profiles
    FOR SELECT USING (tenant_id = get_my_tenant_id());

-- Tenants:
-- A. Public can read names for sign-up
CREATE POLICY "tenants_read_public" ON public.tenants
    FOR SELECT USING (true);

-- Operational Tables (Isolation):
CREATE POLICY "bookings_isolation" ON public.bookings
    FOR ALL USING (tenant_id = get_my_tenant_id());

CREATE POLICY "inventory_isolation" ON public.inventory
    FOR ALL USING (tenant_id = get_my_tenant_id());

CREATE POLICY "status_isolation" ON public.status
    FOR ALL USING (tenant_id = get_my_tenant_id());

DO $$ 
BEGIN 
    RAISE NOTICE '🛡️  SECURITY RESTORED. Tenant isolation is now active and safe.';
END $$;
