-- Standardize inventory table to use snake_case
-- This script renames columns to be consistent with Postgres best practices.
-- It is idempotent and can be safely run multiple times.

DO $$ 
BEGIN
    -- 1. Rename columns if they exist in camelCase
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'currentStock') THEN
        ALTER TABLE public.inventory RENAME COLUMN "currentStock" TO current_stock;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'minStockLevel') THEN
        ALTER TABLE public.inventory RENAME COLUMN "minStockLevel" TO min_stock_level;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'reorderLevel') THEN
        ALTER TABLE public.inventory RENAME COLUMN "reorderLevel" TO reorder_level;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'costPerUnit') THEN
        ALTER TABLE public.inventory RENAME COLUMN "costPerUnit" TO cost_per_unit;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'lastRestocked') THEN
        ALTER TABLE public.inventory RENAME COLUMN "lastRestocked" TO last_restocked;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'viscosityGrade') THEN
        ALTER TABLE public.inventory RENAME COLUMN "viscosityGrade" TO viscosity_grade;
    END IF;
END $$;

-- 2. Add maintenance columns
ALTER TABLE public.inventory ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Ensure RLS is enabled
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

-- 4. Re-create isolation policy (ensuring it uses tenant_id)
DROP POLICY IF EXISTS "Tenant isolation for inventory" ON public.inventory;
CREATE POLICY "Tenant isolation for inventory" ON public.inventory
    FOR ALL USING (tenant_id = get_user_tenant_id());

-- 5. Enable Realtime for the inventory table
-- This is CRITICAL for the .stream() query in the app to work.
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;
    
    -- Add the table to the publication if not already there
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'inventory'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.inventory;
    END IF;
END $$;

-- Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'inventory' 
ORDER BY ordinal_position;

SELECT pubname, schemaname, tablename 
FROM pg_publication_tables 
WHERE tablename = 'inventory';
