# SharpSweep Admin Guide

## Accessing Backend Data

### Supabase Dashboard

All your backend data is stored in Supabase. You can access it at:

**Supabase Dashboard:** https://hmxkibcsvxgjmczqsqjp.supabase.co

Login with your Supabase account credentials.

---

## Database Tables

### 1. **sportsbooks**
Manages all sportsbooks and their affiliate links.

**Location:** Table Editor → sportsbooks

**Columns:**
- `id` - Unique identifier
- `name` - Sportsbook name (e.g., "FanDuel", "DraftKings")
- `logo_url` - Logo image URL (optional)
- `affiliate_link` - Your affiliate/referral link
- `is_active` - Whether the sportsbook is active
- `display_order` - Sort order for display
- `created_at` / `updated_at` - Timestamps

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor" in the left sidebar
3. Select "sportsbooks" table
4. View all sportsbooks and their affiliate links

**In-App Management:**
- Open the app
- Click "My Hub" (top right)
- Select "⚙️ Sportsbook Admin"
- Add, edit, or delete sportsbooks and affiliate links

---

### 2. **lines**
Stores all betting lines from real sportsbooks.

**Location:** Table Editor → lines

**Columns:**
- `id` - Unique identifier
- `game_id` - Unique game identifier
- `home_team` / `away_team` - Team names
- `sport` - Sport type (nfl, nba, nhl)
- `sportsbook_id` - Reference to sportsbooks table
- `spread` / `spread_odds` - Point spread and odds
- `total` / `total_odds` - Over/under total and odds
- `moneyline_home` / `moneyline_away` - Moneyline odds
- `game_time` - When the game starts
- `is_active` - Whether the line is currently active

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "lines" table
4. View all betting lines from all sportsbooks

**How to Sync Real Odds:**
1. Open the app
2. Go to "⚙️ Sportsbook Admin"
3. Click "🔄 Sync Real Odds"
4. Lines will be fetched from The Odds API and stored here

---

### 3. **user_profiles**
Stores user subscription tiers and swipe limits.

**Location:** Table Editor → user_profiles

**Columns:**
- `id` - User ID (links to auth.users)
- `tier` - Subscription level (FREE, PLUS, PRO, ELITE)
- `swipes_used` - Number of swipes used this month
- `swipes_reset_at` - When swipes reset (3AM EST)
- `created_at` / `updated_at` - Timestamps

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "user_profiles" table
4. See all users and their subscription tiers

---

### 4. **swipes**
Tracks every user interaction with betting lines.

**Location:** Table Editor → swipes

**Columns:**
- `id` - Unique identifier
- `user_id` - Who swiped (links to auth.users)
- `line_id` - Which line was swiped (links to lines table)
- `direction` - "confident" or "doubt"
- `status` - "mybias", "mylocks", or "myarchives"
- `sportsbook_cart` - Cart organization (optional)
- `swiped_from` - Where the swipe occurred
- `created_at` - When the swipe happened

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "swipes" table
4. See all user swipes and their choices

**Analytics Queries:**
```sql
-- Most popular lines (by swipe count)
SELECT
  l.home_team,
  l.away_team,
  l.sport,
  COUNT(s.id) as swipe_count
FROM swipes s
JOIN lines l ON s.line_id = l.id
GROUP BY l.home_team, l.away_team, l.sport
ORDER BY swipe_count DESC
LIMIT 10;

-- User confidence vs doubt ratio
SELECT
  user_id,
  COUNT(CASE WHEN direction = 'confident' THEN 1 END) as confident_count,
  COUNT(CASE WHEN direction = 'doubt' THEN 1 END) as doubt_count
FROM swipes
GROUP BY user_id;
```

---

### 5. **community_bias**
Aggregated community sentiment for each line.

**Location:** Table Editor → community_bias

**Columns:**
- `line_id` - Which line (links to lines table)
- `confident_count` - Number of "confident" swipes
- `doubt_count` - Number of "doubt" swipes
- `updated_at` - Last updated timestamp

**How It Works:**
- Automatically updated via database trigger when users swipe
- Shows real-time community sentiment
- Displayed in the app's bias meter (green bar)

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "community_bias" table
4. See aggregate swipe counts for each line

---

### 6. **user_interactions**
Tracks all user clicks and behaviors for analytics.

**Location:** Table Editor → user_interactions

**Columns:**
- `id` - Unique identifier
- `user_id` - Who performed the action
- `line_id` - Related line (if applicable)
- `sportsbook_id` - Related sportsbook (if applicable)
- `interaction_type` - Type: 'view', 'click', 'affiliate_click', 'line_view'
- `screen` - Where it happened ('LineDetails', 'MyLocks', etc.)
- `metadata` - Additional context (JSON)
- `created_at` - When it happened

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "user_interactions" table
4. Track user behavior and affiliate link clicks

**Analytics Queries:**
```sql
-- Affiliate click-through rate by sportsbook
SELECT
  s.name as sportsbook_name,
  COUNT(ui.id) as click_count
FROM user_interactions ui
JOIN sportsbooks s ON ui.sportsbook_id = s.id
WHERE ui.interaction_type = 'affiliate_click'
GROUP BY s.name
ORDER BY click_count DESC;

-- Most viewed lines
SELECT
  l.home_team,
  l.away_team,
  COUNT(ui.id) as view_count
FROM user_interactions ui
JOIN lines l ON ui.line_id = l.id
WHERE ui.interaction_type = 'line_view'
GROUP BY l.home_team, l.away_team
ORDER BY view_count DESC
LIMIT 10;
```

---

### 7. **line_snapshots**
Historical snapshots of lines taken daily at 3AM EST.

**Location:** Table Editor → line_snapshots

**Columns:**
- `id` - Unique identifier
- `line_id` - Which line (links to lines table)
- `snapshot_date` - Date of snapshot
- `home_team` / `away_team` - Team names
- `spread` / `spread_odds` / `total` / `total_odds` - Odds at snapshot time
- `confident_count` / `doubt_count` - Community bias at snapshot time

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select "line_snapshots" table
4. View historical line data and community sentiment

---

## Setting Up The Odds API

To fetch real betting lines, you need an API key from The Odds API.

### Step 1: Get API Key

1. Go to https://the-odds-api.com/
2. Click "Get API Key" (free tier: 500 requests/month)
3. Sign up and copy your API key

### Step 2: Configure Secret in Supabase

1. Go to your Supabase Dashboard
2. Click "Project Settings" (gear icon in left sidebar)
3. Click "Edge Functions" in the left menu
4. Click "Manage secrets"
5. Add a new secret:
   - Name: `ODDS_API_KEY`
   - Value: Your API key from The Odds API
6. Click "Save"

### Step 3: Sync Odds

1. Open your SharpSweep app
2. Sign in
3. Go to "My Hub" → "⚙️ Sportsbook Admin"
4. Click "🔄 Sync Real Odds"
5. Wait for confirmation message

The app will fetch:
- NFL games (americanfootball_nfl)
- NBA games (basketball_nba)
- NHL games (icehockey_nhl)

Lines include spreads, totals, and moneylines from multiple sportsbooks.

---

## SQL Editor for Custom Queries

For advanced analytics, use the SQL Editor in Supabase:

1. Go to Supabase Dashboard
2. Click "SQL Editor" in the left sidebar
3. Write custom queries to analyze your data

### Example Queries:

**Most popular sportsbooks:**
```sql
SELECT
  s.name,
  COUNT(DISTINCT sw.user_id) as unique_users,
  COUNT(sw.id) as total_swipes
FROM swipes sw
JOIN lines l ON sw.line_id = l.id
JOIN sportsbooks s ON l.sportsbook_id = s.id
GROUP BY s.name
ORDER BY total_swipes DESC;
```

**Daily active users:**
```sql
SELECT
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as daily_active_users
FROM swipes
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

**User tier distribution:**
```sql
SELECT
  tier,
  COUNT(*) as user_count
FROM user_profiles
GROUP BY tier
ORDER BY user_count DESC;
```

---

## Authentication & User Management

### User Table

**Location:** Authentication → Users

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Authentication" in the left sidebar
3. Click "Users" tab
4. View all registered users, emails, and sign-up dates

### Manage Users:
- View user email addresses
- See last sign-in times
- Manually delete users if needed
- Reset user passwords

---

## Edge Functions

Your app has one Edge Function deployed:

### fetch-odds
Fetches real betting lines from The Odds API.

**Location:** Edge Functions → fetch-odds

**How to Access:**
1. Go to Supabase Dashboard
2. Click "Edge Functions" in the left sidebar
3. Click "fetch-odds" to view logs and details

**How It Works:**
- Called when you click "🔄 Sync Real Odds" in admin
- Fetches odds for NFL, NBA, and NHL
- Creates or updates lines in the database
- Creates sportsbooks if they don't exist

**View Logs:**
1. Go to Edge Functions → fetch-odds
2. Click "Logs" tab
3. See execution history and any errors

---

## API Access

You can also access your data via the Supabase REST API.

**Base URL:** https://hmxkibcsvxgjmczqsqjp.supabase.co/rest/v1/

**Authentication:** Use your anon key or service role key from Settings → API

Example API call:
```bash
curl https://hmxkibcsvxgjmczqsqjp.supabase.co/rest/v1/lines?select=* \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

---

## Monitoring & Analytics

### Real-time Database Changes

Watch database changes in real-time:

1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Select any table
4. Changes appear instantly as users interact with your app

### Storage Usage

Check your database size:

1. Go to Supabase Dashboard
2. Click "Settings" → "Usage"
3. View:
   - Database size
   - API requests
   - Bandwidth usage
   - Active users

---

## Support

If you need help accessing your data:

- **Supabase Documentation:** https://supabase.com/docs
- **The Odds API Documentation:** https://the-odds-api.com/liveapi/guides/v4/
- **SQL Query Help:** https://supabase.com/docs/guides/database/overview

---

## Quick Reference

| Data | Location | Purpose |
|------|----------|---------|
| Sportsbooks & Affiliate Links | Table Editor → sportsbooks | Manage betting platforms and affiliate links |
| Betting Lines | Table Editor → lines | Real odds from sportsbooks |
| User Swipes | Table Editor → swipes | Track all user picks (confident/doubt) |
| Community Sentiment | Table Editor → community_bias | Aggregated swipe data per line |
| User Profiles | Table Editor → user_profiles | Subscription tiers and limits |
| User Behavior | Table Editor → user_interactions | Analytics on clicks and views |
| Historical Data | Table Editor → line_snapshots | Daily 3AM snapshots of lines |
| Registered Users | Authentication → Users | Email addresses and auth data |
| API Logs | Edge Functions → fetch-odds | Odds sync execution logs |

---

Your data is secure, backed up automatically, and accessible 24/7 via the Supabase Dashboard.
