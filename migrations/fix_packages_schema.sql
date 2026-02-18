-- Standardize packages table to use snake_case
ALTER TABLE public.packages RENAME COLUMN "includedServiceIds" TO included_service_ids;
ALTER TABLE public.packages RENAME COLUMN "isActive" TO is_active;
ALTER TABLE public.packages RENAME COLUMN "createdAt" TO created_at;

-- Add savings column if not present (to match model)
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS savings TEXT;

-- Verify
SELECT * FROM public.packages LIMIT 1;
