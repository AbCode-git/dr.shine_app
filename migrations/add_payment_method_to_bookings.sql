-- Migration: Add Payment Method to Bookings
-- Description: Adds a column to track the payment type (Cash, Telebirr, CBE) for each booking.

ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS payment_method TEXT CHECK (payment_method IN ('cash', 'telebirr', 'cbe'));

-- Comment on column for clarity
COMMENT ON COLUMN public.bookings.payment_method IS 'The method of payment used for this booking: cash, telebirr, or cbe.';
