/*
  # Add Unique Constraint for Lines Upsert

  1. Changes
    - Add unique constraint on (game_id, sportsbook_id) for the lines table
    - This allows the Edge Function to upsert lines without duplicates
    - Drop the old sportsbook text column if it exists
  
  2. Notes
    - This enables efficient updates when odds change
    - Prevents duplicate lines for the same game and sportsbook
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lines' AND column_name = 'sportsbook'
  ) THEN
    ALTER TABLE lines DROP COLUMN sportsbook;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'lines_game_id_sportsbook_id_key'
  ) THEN
    ALTER TABLE lines ADD CONSTRAINT lines_game_id_sportsbook_id_key UNIQUE (game_id, sportsbook_id);
  END IF;
END $$;