# How to Access Your Supabase Tables

## Quick Access

**Your Supabase Dashboard:**
https://hmxkibcsvxgjmczqsqjp.supabase.co

---

## Step-by-Step: Viewing Your Tables

### 1. Login to Supabase

1. Go to https://supabase.com/dashboard
2. Click "Sign in"
3. Use the email/password you created your Supabase account with
4. Your project "hmxkibcsvxgjmczqsqjp" should appear

### 2. Access Table Editor

1. Click on your project
2. In the left sidebar, click **"Table Editor"** (looks like a grid icon)
3. You'll see a list of all your tables

### 3. View Your Tables

Your SharpSweep app has these tables:

#### **lines** - Real betting lines
- Click "lines" in the left sidebar
- View all betting lines from sportsbooks
- Columns: game_id, home_team, away_team, spread, total, moneyline, etc.

#### **sportsbooks** - Betting platforms
- Click "sportsbooks"
- View all sportsbooks and affiliate links
- Add/edit sportsbook details here

#### **swipes** - User interactions
- Click "swipes"
- View all user swipes (confident/doubt)
- See which lines users are most interested in

#### **community_bias** - Aggregate sentiment
- Click "community_bias"
- View total swipe counts per line
- See confident_count vs doubt_count

#### **user_profiles** - User subscription tiers
- Click "user_profiles"
- View user tiers (FREE, PLUS, PRO, ELITE)
- See swipe usage

#### **user_interactions** - Analytics tracking
- Click "user_interactions"
- Track clicks, views, affiliate clicks
- Monitor user behavior

#### **line_snapshots** - Historical data
- Click "line_snapshots"
- View daily 3AM snapshots of lines
- Historical odds and sentiment

---

## Step-by-Step: Creating a New Table

If you need to create a new table:

### 1. Access SQL Editor

1. In your Supabase dashboard
2. Click **"SQL Editor"** in the left sidebar
3. Click "New query"

### 2. Write SQL to Create Table

Example - Creating a "favorites" table:

```sql
CREATE TABLE IF NOT EXISTS favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  line_id uuid REFERENCES lines(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own favorites
CREATE POLICY "Users can view own favorites"
  ON favorites
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own favorites
CREATE POLICY "Users can insert own favorites"
  ON favorites
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

### 3. Run the Query

1. Click "Run" or press Ctrl+Enter
2. Check for success message
3. Go to Table Editor to see your new table

---

## Step-by-Step: Editing Data in Tables

### Using Table Editor (Visual)

1. Go to Table Editor
2. Click on any table (e.g., "sportsbooks")
3. Click "Insert row" to add new data
4. Click on any cell to edit existing data
5. Click "Save" after making changes

### Using SQL Editor (Advanced)

1. Go to SQL Editor
2. Write a query:

```sql
-- Example: Update a sportsbook's affiliate link
UPDATE sportsbooks
SET affiliate_link = 'https://your-new-link.com'
WHERE name = 'FanDuel';
```

3. Click "Run"

---

## Step-by-Step: Querying Your Data

### Common Queries

**1. View all betting lines for today:**
```sql
SELECT
  home_team,
  away_team,
  spread,
  total,
  game_time
FROM lines
WHERE DATE(game_time) = CURRENT_DATE
  AND is_active = true
ORDER BY game_time;
```

**2. Most popular lines (by swipe count):**
```sql
SELECT
  l.home_team,
  l.away_team,
  COUNT(s.id) as swipe_count,
  SUM(CASE WHEN s.direction = 'confident' THEN 1 ELSE 0 END) as confident,
  SUM(CASE WHEN s.direction = 'doubt' THEN 1 ELSE 0 END) as doubt
FROM swipes s
JOIN lines l ON s.line_id = l.id
GROUP BY l.home_team, l.away_team
ORDER BY swipe_count DESC
LIMIT 10;
```

**3. User activity by day:**
```sql
SELECT
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as active_users,
  COUNT(*) as total_swipes
FROM swipes
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

**4. Affiliate link click-through rates:**
```sql
SELECT
  s.name as sportsbook,
  COUNT(*) as click_count
FROM user_interactions ui
JOIN sportsbooks s ON ui.sportsbook_id = s.id
WHERE ui.interaction_type = 'affiliate_click'
GROUP BY s.name
ORDER BY click_count DESC;
```

---

## Step-by-Step: Exporting Data

### Export from Table Editor

1. Go to Table Editor
2. Select a table
3. Click the three dots menu (⋮) in top right
4. Click "Export as CSV"
5. Data downloads to your computer

### Export via SQL

1. Go to SQL Editor
2. Run your query
3. Click "Download results" below the results
4. Choose CSV or JSON format

---

## Step-by-Step: Viewing Real-Time Data

### Watch Changes Live

1. Go to Table Editor
2. Click on any table
3. Data automatically refreshes
4. You'll see new rows appear as users interact with your app

### Enable Auto-refresh

1. In Table Editor
2. Look for the refresh icon (🔄) in top right
3. Data updates every few seconds

---

## Step-by-Step: Managing Users

### View All Users

1. In the left sidebar, click **"Authentication"**
2. Click **"Users"** tab
3. See all registered users, emails, and sign-up dates

### User Actions

- **View user details:** Click on any user
- **Delete a user:** Click three dots (⋮) → Delete user
- **Reset password:** Click three dots (⋮) → Send password reset
- **View user metadata:** Click user → see app_metadata and user_metadata

---

## Step-by-Step: Monitoring Edge Functions

### View Sync Logs

1. In left sidebar, click **"Edge Functions"**
2. Click **"fetch-odds"** function
3. Click **"Logs"** tab
4. See all sync executions, timestamps, and any errors

### Check Function Status

- Green dot = Function is deployed and healthy
- Red dot = Function has errors
- View logs to debug issues

---

## Troubleshooting Common Issues

### "Table doesn't exist"

**Solution:**
- Your migrations may not have run
- Go to SQL Editor and run the migration files manually
- Files are in `supabase/migrations/` folder

### "Permission denied"

**Solution:**
- Check Row Level Security (RLS) policies
- Go to Table Editor → Click table → "Policies" tab
- Ensure policies allow your actions

### "Can't see my data"

**Solution:**
- Check the "Filters" bar at the top of Table Editor
- Click "Clear filters" to see all data
- Ensure you're looking at the right table

### "SQL query failed"

**Solution:**
- Check for typos in table/column names
- Ensure proper syntax (semicolons, commas)
- View error message for specific details

---

## Quick Reference Chart

| What You Want | Where to Go | Action |
|---------------|-------------|--------|
| View betting lines | Table Editor → lines | Browse rows |
| View user swipes | Table Editor → swipes | Browse rows |
| View sportsbooks | Table Editor → sportsbooks | Browse rows |
| Edit affiliate links | Table Editor → sportsbooks | Click cell → Edit |
| See user emails | Authentication → Users | View list |
| Check sync logs | Edge Functions → fetch-odds → Logs | View executions |
| Run custom query | SQL Editor | Write SQL → Run |
| Export data | Table Editor → ⋮ menu | Export as CSV |
| Create new table | SQL Editor | Write CREATE TABLE → Run |
| View community stats | Table Editor → community_bias | Browse rows |

---

## Visual Guide

```
Supabase Dashboard
│
├── 📊 Table Editor (Most used!)
│   ├── lines (betting odds)
│   ├── swipes (user picks)
│   ├── sportsbooks (affiliate links)
│   ├── community_bias (aggregate data)
│   ├── user_profiles (subscription tiers)
│   ├── user_interactions (analytics)
│   └── line_snapshots (historical)
│
├── 🔐 Authentication
│   └── Users (emails, sign-up dates)
│
├── ⚡ Edge Functions
│   └── fetch-odds (sync logs)
│
├── 📝 SQL Editor
│   └── Run custom queries
│
└── ⚙️ Project Settings
    └── Edge Functions → Manage secrets (API keys)
```

---

## Next Steps

After accessing your tables:

1. ✅ Add your API key (see API_KEY_SETUP.md)
2. ✅ Sync real odds in the app
3. ✅ Go to Table Editor → lines to verify data
4. ✅ Add affiliate links in Table Editor → sportsbooks
5. ✅ Monitor user activity in Table Editor → swipes
6. ✅ Export data for analysis

Your database is live and updating in real-time as users interact with your app!
