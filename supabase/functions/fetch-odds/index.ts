import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface OddsAPIGame {
  id: string;
  sport_key: string;
  sport_title: string;
  commence_time: string;
  home_team: string;
  away_team: string;
  bookmakers: Array<{
    key: string;
    title: string;
    markets: Array<{
      key: string;
      outcomes: Array<{
        name: string;
        price: number;
        point?: number;
      }>;
    }>;
  }>;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const oddsApiKey = Deno.env.get("ODDS_API_KEY");
    if (!oddsApiKey) {
      return new Response(
        JSON.stringify({ error: "ODDS_API_KEY not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const sports = ["americanfootball_nfl", "basketball_nba", "icehockey_nhl"];
    const regions = "us";
    const markets = "h2h,spreads,totals";
    const oddsFormat = "american";

    let allGamesProcessed = 0;
    let allLinesInserted = 0;

    for (const sport of sports) {
      const oddsUrl = `https://api.the-odds-api.com/v4/sports/${sport}/odds/?apiKey=${oddsApiKey}&regions=${regions}&markets=${markets}&oddsFormat=${oddsFormat}`;

      const oddsResponse = await fetch(oddsUrl);
      if (!oddsResponse.ok) {
        console.error(`Failed to fetch odds for ${sport}: ${oddsResponse.statusText}`);
        continue;
      }

      const games: OddsAPIGame[] = await oddsResponse.json();
      allGamesProcessed += games.length;

      for (const game of games) {
        const sportKey = game.sport_key.includes("nfl") ? "nfl" : 
                         game.sport_key.includes("nba") ? "nba" : "nhl";
        
        const gameId = `${sportKey}_${game.home_team}_vs_${game.away_team}_${game.commence_time}`;

        for (const bookmaker of game.bookmakers) {
          const { data: sportsbookData } = await supabase
            .from("sportsbooks")
            .select("id")
            .eq("name", bookmaker.title)
            .maybeSingle();

          let sportsbookId = sportsbookData?.id;

          if (!sportsbookId) {
            const { data: newSportsbook } = await supabase
              .from("sportsbooks")
              .insert({
                name: bookmaker.title,
                is_active: true,
                display_order: 999,
              })
              .select("id")
              .single();
            sportsbookId = newSportsbook?.id;
          }

          if (!sportsbookId) continue;

          let spread = null;
          let spreadOdds = null;
          let total = null;
          let totalOdds = null;
          let moneylineHome = null;
          let moneylineAway = null;

          for (const market of bookmaker.markets) {
            if (market.key === "spreads") {
              const homeSpread = market.outcomes.find(o => o.name === game.home_team);
              if (homeSpread) {
                spread = homeSpread.point;
                spreadOdds = homeSpread.price;
              }
            } else if (market.key === "totals") {
              const overOutcome = market.outcomes.find(o => o.name === "Over");
              if (overOutcome) {
                total = overOutcome.point;
                totalOdds = overOutcome.price;
              }
            } else if (market.key === "h2h") {
              const homeML = market.outcomes.find(o => o.name === game.home_team);
              const awayML = market.outcomes.find(o => o.name === game.away_team);
              if (homeML) moneylineHome = homeML.price;
              if (awayML) moneylineAway = awayML.price;
            }
          }

          const lineData = {
            game_id: gameId,
            home_team: game.home_team,
            away_team: game.away_team,
            sport: sportKey,
            sportsbook_id: sportsbookId,
            spread,
            spread_odds: spreadOdds,
            total,
            total_odds: totalOdds,
            moneyline_home: moneylineHome,
            moneyline_away: moneylineAway,
            game_time: game.commence_time,
            is_active: true,
          };

          const { error } = await supabase
            .from("lines")
            .upsert(lineData, {
              onConflict: "game_id,sportsbook_id",
            });

          if (!error) {
            allLinesInserted++;
          } else {
            console.error("Error inserting line:", error);
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Processed ${allGamesProcessed} games, inserted/updated ${allLinesInserted} lines`,
        gamesProcessed: allGamesProcessed,
        linesInserted: allLinesInserted,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in fetch-odds:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});