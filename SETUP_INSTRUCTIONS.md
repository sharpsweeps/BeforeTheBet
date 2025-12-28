# SharpSweep Setup Instructions

## Quick Start Guide for Real Odds Integration

### Prerequisites

- Supabase account (already set up)
- The Odds API account (free tier available)
- Access to your Supabase dashboard

---

## Step 1: Get Your Odds API Key

1. Visit https://the-odds-api.com/
2. Click "Get API Key" in the top right
3. Sign up for a free account (500 requests/month)
4. Copy your API key from the dashboard

**Free Tier Limits:**
- 500 API requests per month
- Updates every 15 minutes
- Access to 30+ sportsbooks
- Covers NFL, NBA, NHL, MLB, and more

---

## Step 2: Configure Supabase Secret

1. Go to your Supabase Dashboard: https://hmxkibcsvxgjmczqsqjp.supabase.co
2. Click the gear icon (⚙️) in the bottom left for "Project Settings"
3. In the left menu, click "Edge Functions"
4. Click "Manage secrets" button
5. Add a new secret:
   - **Name:** `ODDS_API_KEY`
   - **Value:** (paste your API key from The Odds API)
6. Click "Save"

---

## Step 3: Sync Real Odds Data

1. Open your SharpSweep app
2. Sign in with your account
3. Click "My Hub" in the top right corner
4. Select "⚙️ Sportsbook Admin"
5. Click the blue "🔄 Sync Real Odds" button
6. Wait for the success message (usually 10-30 seconds)

**What Happens:**
- Fetches current odds for NFL, NBA, and NHL games
- Stores spreads, totals, and moneylines from 6+ sportsbooks
- Creates sportsbook entries automatically
- Updates the app with real betting lines

**Success Message:**
```
Success! X games, Y lines synced
```

---

## Step 4: Add Affiliate Links

After syncing odds, add your affiliate links to earn commissions:

1. Still in "Sportsbook Admin", you'll see a list of sportsbooks
2. Click "Edit" on any sportsbook
3. Add your affiliate link in the "Affiliate Link" field
4. Set the display order (lower numbers appear first)
5. Toggle "Active" to show/hide the sportsbook
6. Click "Save"

**Example Affiliate Link:**
```
https://sportsbook.fanduel.com/r/YOURCODE
```

Now when users click "PLACE BET" buttons, they'll be sent to your affiliate link!

---

## Step 5: Schedule Automatic Syncs (Optional)

To keep your odds fresh, you can set up automatic syncs using Supabase Cron Jobs:

1. Go to Supabase Dashboard
2. Click "Database" → "Cron Jobs" (or use SQL Editor)
3. Run this SQL to create a cron job:

```sql
SELECT cron.schedule(
  'sync-odds-hourly',
  '0 * * * *',  -- Every hour
  $$
  SELECT
    net.http_post(
      url:='https://hmxkibcsvxgjmczqsqjp.supabase.co/functions/v1/fetch-odds',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
    );
  $$
);
```

**Replace `YOUR_SERVICE_ROLE_KEY`** with your actual service role key from:
- Project Settings → API → service_role (secret)

**Warning:** Service role keys bypass RLS. Keep them secret!

---

## How the System Works

### 1. Data Flow

```
The Odds API
     ↓
fetch-odds Edge Function
     ↓
Supabase Database (lines table)
     ↓
SharpSweep App (loads on startup)
     ↓
Users see real betting lines
```

### 2. User Interaction Tracking

When users interact with lines:

```
User swipes "Confident" or "Doubt"
     ↓
Stored in swipes table
     ↓
Database trigger updates community_bias
     ↓
Real-time bias meter updates (0 → actual counts)
```

### 3. Bias Meter Display Logic

**Before any swipes:**
- Shows: "Doubt It: 0" | "Confident: 0"
- Color: Blue (50/50 bar)

**After 1-4 swipes (community locked):**
- Shows: "Doubt It: 45%" | "Confident: 55%"
- Color: Blue (locked)

**After 5+ swipes (community unlocked):**
- Shows: "Doubt It: 45% (18)" | "Confident: 55% (22)"
- Color: Green (unlocked)
- Numbers in parentheses = actual swipe counts

---

## Accessing Your Data

All your data is stored in Supabase. See `ADMIN_GUIDE.md` for detailed instructions.

**Quick Access:**
- **Dashboard:** https://hmxkibcsvxgjmczqsqjp.supabase.co
- **Tables:** Table Editor (left sidebar)
- **Users:** Authentication → Users
- **Logs:** Edge Functions → fetch-odds → Logs

**Key Tables:**
- `lines` - All betting lines from sportsbooks
- `swipes` - User picks (confident/doubt)
- `community_bias` - Aggregate sentiment per line
- `sportsbooks` - Your affiliate links
- `user_interactions` - Click tracking for analytics

---

## Troubleshooting

### "Error: ODDS_API_KEY not configured"

**Solution:** You haven't added the API key secret in Supabase.
1. Go to Project Settings → Edge Functions → Manage secrets
2. Add `ODDS_API_KEY` with your API key
3. Try syncing again

### "No lines synced" or "0 games processed"

**Possible causes:**
1. No upcoming games in the next 7 days
2. The Odds API is down (check https://the-odds-api.com/status)
3. Your API key is invalid or expired

**Solution:**
- Check https://the-odds-api.com/ to see if games are available
- Verify your API key is correct
- Check Edge Function logs for errors

### "Bias meter still shows 50/50 blue"

**Expected behavior:**
- Blue bar = No swipes yet OR community is locked (< 5 swipes in session)
- It should show "0" counts instead of "50%"

**If it's not working:**
1. Hard refresh the app (Ctrl+Shift+R / Cmd+Shift+R)
2. Check that `loadRealGames()` is being called
3. Verify community_bias table has data

### Lines not updating in app

**Solution:**
1. Click "🔄 Sync Real Odds" in admin
2. Hard refresh the page
3. Check browser console for errors (F12)

---

## API Rate Limits

**Free Tier (The Odds API):**
- 500 requests/month
- Each sync uses 3 requests (NFL, NBA, NHL)
- ~166 syncs per month
- Recommended: Sync every 4-6 hours

**If you exceed limits:**
- Upgrade to paid plan ($50/month for 10,000 requests)
- Reduce sync frequency
- Focus on one sport only

---

## Best Practices

1. **Sync Timing:**
   - Sync before peak hours (mornings, evenings)
   - Sync after linemaker updates (typically 10AM-12PM EST)

2. **Affiliate Links:**
   - Use unique tracking codes for each sportsbook
   - Test links before adding them
   - Monitor click-through rates in `user_interactions` table

3. **Data Management:**
   - Clean up old lines weekly (set `is_active = false`)
   - Archive completed games for historical analysis
   - Export data regularly for backup

4. **User Experience:**
   - Keep sportsbooks list updated
   - Disable inactive sportsbooks
   - Set proper display order (most popular first)

---

## Support Resources

- **The Odds API Docs:** https://the-odds-api.com/liveapi/guides/v4/
- **Supabase Docs:** https://supabase.com/docs
- **Edge Functions Guide:** https://supabase.com/docs/guides/functions
- **SQL Help:** https://supabase.com/docs/guides/database

---

## Next Steps

After setup:

1. ✅ Test the sync by clicking "🔄 Sync Real Odds"
2. ✅ Verify lines appear in Table Editor → lines
3. ✅ Add your affiliate links in Sportsbook Admin
4. ✅ Make some test swipes to see bias meter in action
5. ✅ Set up automatic syncs (optional)
6. ✅ Review ADMIN_GUIDE.md for data access instructions

Your app is now pulling real betting lines and tracking real user behavior!
