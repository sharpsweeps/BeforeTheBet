# Add Your Odds API Key - Quick Guide

Your API Key: `babc6248c4770a2721e9133c9e794b14`

## Add the Secret to Supabase (2 minutes)

### Option 1: Using Supabase Dashboard (Recommended)

1. **Go to your dashboard:**
   https://hmxkibcsvxgjmczqsqjp.supabase.co

2. **Navigate to secrets:**
   - Click the gear icon ⚙️ in the bottom left (Project Settings)
   - Click "Edge Functions" in the left menu
   - Click the "Manage secrets" button

3. **Add your secret:**
   - Click "New secret" or "Add new secret"
   - Name: `ODDS_API_KEY`
   - Value: `babc6248c4770a2721e9133c9e794b14`
   - Click "Save" or "Create"

4. **Done!** The secret is now available to your Edge Functions.

### Option 2: Using Supabase CLI (Advanced)

If you have the Supabase CLI installed:

```bash
supabase secrets set ODDS_API_KEY=babc6248c4770a2721e9133c9e794b14
```

---

## After Adding the Secret

Once you've added the secret, you can sync real odds:

1. Open your SharpSweep app
2. Sign in to your account
3. Click "My Hub" (top right)
4. Select "⚙️ Sportsbook Admin"
5. Click "🔄 Sync Real Odds"
6. Wait 10-30 seconds for success message

**Expected Result:**
```
Success! [X] games, [Y] lines synced
```

This will fetch:
- NFL games with spreads, totals, moneylines
- NBA games with spreads, totals, moneylines
- NHL games with spreads, totals, moneylines
- From 6+ major sportsbooks (FanDuel, DraftKings, BetMGM, etc.)

---

## Your API Key Details

- **Key:** `babc6248c4770a2721e9133c9e794b14`
- **Tier:** Free (500 requests/month)
- **Each sync uses:** 3 requests (one per sport)
- **Max syncs per month:** ~166 times
- **Recommended frequency:** Every 4-6 hours

---

## Verify It's Working

After syncing, check in Supabase:
1. Go to Table Editor → `lines` table
2. You should see rows with real team names, odds, and game times
3. Check `sportsbooks` table to see which books were added

If you see data, it's working! 🎉
