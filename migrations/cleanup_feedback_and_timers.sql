-- Migration: Cleanup Feedback and Wash Timers
-- Description: Removes the feedback table and wash duration tracking columns/triggers

-- 1. Remove feedback table
DROP TABLE IF EXISTS public.feedback CASCADE;

-- 2. Remove status tracking columns from bookings
-- We drop both snake_case and potential camelCase leftovers
ALTER TABLE public.bookings DROP COLUMN IF EXISTS status_updated_at;
ALTER TABLE public.bookings DROP COLUMN IF EXISTS completed_at;
ALTER TABLE public.bookings DROP COLUMN IF EXISTS "completedAt";

-- 3. Remove associated trigger and function
DROP TRIGGER IF EXISTS tr_update_status_timestamp ON public.bookings;
DROP FUNCTION IF EXISTS update_status_timestamp();

-- 4. Clean up any related helper functions if they are no longer needed
-- (Keeping get_user_tenant_id and is_super_admin as they are likely used by other RLS policies)
