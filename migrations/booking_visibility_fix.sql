-- ============================================
-- BOOKING VISIBILITY & INTERACTION FIX
-- ============================================
-- Allows bookings to be created and updated without a valid Supabase session.
-- This is necessary to support "Mock Admin" mode in standard UI flows.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- Policy: Allow public select for ALL bookings
DROP POLICY IF EXISTS "Bookings_Public_Select" ON public.bookings;
CREATE POLICY "Bookings_Public_Select" ON public.bookings
    FOR SELECT USING (true);

-- Policy: Allow public insert for ALL bookings
DROP POLICY IF EXISTS "Bookings_Public_Insert" ON public.bookings;
CREATE POLICY "Bookings_Public_Insert" ON public.bookings
    FOR INSERT WITH CHECK (true);

-- Policy: Allow public update for ALL bookings
DROP POLICY IF EXISTS "Bookings_Public_Update" ON public.bookings;
CREATE POLICY "Bookings_Public_Update" ON public.bookings
    FOR UPDATE USING (true) WITH CHECK (true);

DO $$ 
BEGIN 
    RAISE NOTICE '✅ Booking interaction policies applied successfully.';
END $$;
