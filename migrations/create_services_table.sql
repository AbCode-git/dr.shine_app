-- ============================================
-- SERVICES TABLE MIGRATION
-- ============================================
-- Moves hardcoded services to a dynamic Supabase table.
-- Supports multi-tenancy and custom pricing.
-- ============================================

CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(id),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    icon TEXT,
    inventory_requirements JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Services_Public_Select" ON public.services;
CREATE POLICY "Services_Public_Select" ON public.services
    FOR SELECT USING (true); -- Public read for now (filtered by tenant in UI)

DROP POLICY IF EXISTS "Services_Admin_Insert" ON public.services;
CREATE POLICY "Services_Admin_Insert" ON public.services
    FOR INSERT WITH CHECK (true); -- Simplified for mock/dev

DROP POLICY IF EXISTS "Services_Admin_Update" ON public.services;
CREATE POLICY "Services_Admin_Update" ON public.services
    FOR UPDATE USING (true);

-- Seed initial data
INSERT INTO public.services (name, description, price, icon)
VALUES 
    ('Exterior Wash', 'Thorough outside cleaning including wheels and tires.', 150.0, 'local_car_wash'),
    ('Interior Cleaning', 'Vacuuming, dashboard wiping, and glass cleaning.', 200.0, 'cleaning_services'),
    ('Full Wash', 'Complete exterior and interior care package.', 300.0, 'stars'),
    ('Oil Change (Synthetic)', 'Full synthetic oil for maximum engine protection.', 6500.0, 'oil_barrel')
ON CONFLICT DO NOTHING;

DO $$ 
BEGIN 
    RAISE NOTICE '✅ Services table created and seeded successfully.';
END $$;
