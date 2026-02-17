-- ============================================
-- CHECK REALTIME (STATUS TABLE)
-- ============================================

SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND tablename = 'status';
