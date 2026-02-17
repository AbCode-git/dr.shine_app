-- Add packageId to bookings table (camelCase to match application model)
ALTER TABLE bookings
ADD COLUMN IF NOT EXISTS "packageId" UUID REFERENCES packages(id) ON DELETE SET NULL;

-- Grant access to authenticated users
GRANT ALL ON bookings TO authenticated;
GRANT ALL ON bookings TO service_role;

-- Reload schema cache (notify Postgrest)
NOTIFY pgrst, 'reload config';
