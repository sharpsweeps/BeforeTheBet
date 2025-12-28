/*
  # Add Admin Policies for Sportsbooks Management

  1. Changes
    - Add policies to allow authenticated users to insert, update, and delete sportsbooks
    - This enables the admin interface to function properly
  
  2. Security
    - Only authenticated users can manage sportsbooks
    - All authenticated users are considered admins for demo purposes
    - In production, you should add role-based access control
*/

CREATE POLICY "Authenticated users can insert sportsbooks"
  ON sportsbooks FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update sportsbooks"
  ON sportsbooks FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete sportsbooks"
  ON sportsbooks FOR DELETE
  TO authenticated
  USING (true);