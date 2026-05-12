-- Optional migration: store who cancelled an appointment for customer/barber hints.
-- Apply in Supabase before relying on differentiated cancel messages.

ALTER TABLE public.appointments
  ADD COLUMN IF NOT EXISTS cancelled_by text;

ALTER TABLE public.appointments
  DROP CONSTRAINT IF EXISTS appointments_cancelled_by_check;

ALTER TABLE public.appointments
  ADD CONSTRAINT appointments_cancelled_by_check
  CHECK (
    cancelled_by IS NULL
    OR cancelled_by IN ('barber', 'customer', 'system')
  );
