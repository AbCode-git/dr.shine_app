-- Create packages table
CREATE TABLE IF NOT EXISTS public.packages (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    price numeric NOT NULL DEFAULT 0,
    "includedServiceIds" text[] DEFAULT '{}'::text[],
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone DEFAULT now(),
    CONSTRAINT packages_pkey PRIMARY KEY (id)
);

-- RLS Policies
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON public.packages
    FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON public.packages
    FOR ALL USING (auth.role() = 'authenticated');
