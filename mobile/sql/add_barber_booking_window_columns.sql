-- Run on Supabase (SQL editor or migration) before using booking window settings.
-- Adds customer booking horizon fields on barbers.

ALTER TABLE public.barbers
  ADD COLUMN IF NOT EXISTS booking_window_enabled boolean NOT NULL DEFAULT false;

ALTER TABLE public.barbers
  ADD COLUMN IF NOT EXISTS booking_window_type text NOT NULL DEFAULT 'month';

ALTER TABLE public.barbers
  DROP CONSTRAINT IF EXISTS barbers_booking_window_type_check;

ALTER TABLE public.barbers
  ADD CONSTRAINT barbers_booking_window_type_check
  CHECK (
    booking_window_type IN (
      'today',
      'today_tomorrow',
      'week',
      'month'
    )
  );
