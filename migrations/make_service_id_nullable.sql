-- Make serviceId nullable to support package-only bookings
ALTER TABLE bookings
ALTER COLUMN "serviceId" DROP NOT NULL;

-- Reload schema cache
NOTIFY pgrst, 'reload config';
