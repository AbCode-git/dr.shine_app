-- Add washer phone number to bookings for better operational tracking
ALTER TABLE bookings 
ADD COLUMN IF NOT EXISTS "washerStaffPhone" TEXT;

-- Update the view or triggers if necessary (optional)
COMMENT ON COLUMN bookings."washerStaffPhone" IS 'The phone number of the washer assigned to this booking, used for ad-hoc tracking.';
