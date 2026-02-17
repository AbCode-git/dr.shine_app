-- ============================================
-- CHECK REALTIME CONFIGURATION
-- ============================================
-- Checks if the 'bookings' table is in the 'supabase_realtime' publication.
-- If it's missing, stream() will not receive updates.
-- ============================================

SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND tablename = 'bookings';
