/*
  # Create Sportsbooks and User Interactions System

  1. New Tables
    - `sportsbooks`
      - `id` (uuid, primary key)
      - `name` (text, unique) - Sportsbook name (e.g., "FanDuel", "DraftKings")
      - `logo_url` (text, nullable) - Logo image URL
      - `affiliate_link` (text, nullable) - Affiliate/referral link for the sportsbook
      - `is_active` (boolean) - Whether sportsbook is currently active
      - `display_order` (integer) - Sort order for display
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `user_interactions`
      - `id` (uuid, primary key)
      - `user_id` (uuid, FK to auth.users) - User who performed the action
      - `line_id` (uuid, FK to lines, nullable) - Related betting line if applicable
      - `sportsbook_id` (uuid, FK to sportsbooks, nullable) - Related sportsbook
      - `interaction_type` (text) - Type: 'view', 'click', 'affiliate_click', 'line_view'
      - `screen` (text, nullable) - Where interaction occurred (e.g., 'LineDetails', 'MyLocks')
      - `metadata` (jsonb, nullable) - Additional context data
      - `created_at` (timestamptz)
  
  2. Changes
    - Update `lines` table to use foreign key reference to sportsbooks
    - Add indexes for efficient querying of user interactions
  
  3. Security
    - Enable RLS on `sportsbooks` table
    - Public read access for active sportsbooks
    - Only authenticated admins can modify sportsbooks
    - Enable RLS on `user_interactions` table
    - Users can insert their own interactions
    - Users can read their own interactions only
  
  4. Seed Data
    - Insert common sportsbooks (FanDuel, DraftKings, BetMGM, Caesars, ESPN BET, PointsBet)
*/

-- Create sportsbooks table
CREATE TABLE IF NOT EXISTS sportsbooks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  logo_url text,
  affiliate_link text,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create user_interactions table
CREATE TABLE IF NOT EXISTS user_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  line_id uuid REFERENCES lines(id) ON DELETE SET NULL,
  sportsbook_id uuid REFERENCES sportsbooks(id) ON DELETE SET NULL,
  interaction_type text NOT NULL,
  screen text,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- Add sportsbook_id column to lines table if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lines' AND column_name = 'sportsbook_id'
  ) THEN
    ALTER TABLE lines ADD COLUMN sportsbook_id uuid REFERENCES sportsbooks(id);
  END IF;
END $$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_id ON user_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_line_id ON user_interactions(line_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_sportsbook_id ON user_interactions(sportsbook_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_type ON user_interactions(interaction_type);
CREATE INDEX IF NOT EXISTS idx_user_interactions_created_at ON user_interactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_lines_sportsbook_id ON lines(sportsbook_id);
CREATE INDEX IF NOT EXISTS idx_sportsbooks_display_order ON sportsbooks(display_order);

-- Enable RLS
ALTER TABLE sportsbooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_interactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for sportsbooks table
CREATE POLICY "Anyone can view active sportsbooks"
  ON sportsbooks FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can view all sportsbooks"
  ON sportsbooks FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for user_interactions table
CREATE POLICY "Users can insert their own interactions"
  ON user_interactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own interactions"
  ON user_interactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Seed common sportsbooks
INSERT INTO sportsbooks (name, display_order, is_active) VALUES
  ('FanDuel', 1, true),
  ('DraftKings', 2, true),
  ('BetMGM', 3, true),
  ('Caesars', 4, true),
  ('ESPN BET', 5, true),
  ('PointsBet', 6, true)
ON CONFLICT (name) DO NOTHING;

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_sportsbooks_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS update_sportsbooks_updated_at_trigger ON sportsbooks;
CREATE TRIGGER update_sportsbooks_updated_at_trigger
  BEFORE UPDATE ON sportsbooks
  FOR EACH ROW
  EXECUTE FUNCTION update_sportsbooks_updated_at();