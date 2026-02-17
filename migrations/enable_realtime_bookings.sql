-- ============================================
-- ENABLE REALTIME FOR BOOKINGS
-- ============================================
-- Supabase needs explicit instructions to broadcast table changes.
-- This ensures the Dashboard updates instantly when status changes.
-- Run this in your Supabase SQL Editor.
-- ============================================

-- Step 1: Ensure the supabase_realtime publication exists
-- (This usually exists by default, but safe to check)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;
END $$;

-- Step 2: Add the tables to the publication
-- We use ALTER here to ensure they are joined if already exist
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;

DO $$ 
BEGIN 
    RAISE NOTICE '✅ Realtime broadcasting enabled for bookings and profiles.';
END $$;
