# CFB2026 — NCAA FBS Weekly Pairwise Game Prediction

A machine learning and statistical modeling pipeline for predicting weekly **NCAA FBS Power 4 (P4)** college football game outcomes.

---

## System Overview & Architecture

The workflow ingests play-by-play data, constructs walk-forward temporal features, trains multiple sequence and tabular models, and benchmarks predictions against market lines and rating-implied spreads.


CFBfastR (R) --> ingest (01) --> PostgreSQL `cfb` schema
|
feature eng (03) --> tabular_features.rds
|             team_sequences.rds
v
model comparison (04): elo_logit / xgboost /
gru / lstm / transformer
|
champion model selected
v
weekly predict + compare (05) --> predictions table
|              + week{N}_comparison.csv
v
vs. Vegas consensus spread, FPI-implied, Elo-implied

```

---

## Season Rules & Scope
* **Temporal Boundaries:** Models track game data across regular season through conference championship weeks (Weeks 0–15).
* **Playoff Structure:** Accommodates the 12-team CFP format (Seeds 1–4 get byes; 5 automatic qualifiers + 7 at-larges; campus-site first rounds).
* **Opponent Parity (Like-to-Like Filtering):** Non-Power 4 matchups (vs. G5, FCS, or unclassified opponents) are excluded from rolling team-rating statistics to ensure models evaluate teams strictly against like-for-like competition.
  * *Independents:* Notre Dame, UConn, and UMass are classified via `teams.tier_override` in `01_ingest_cfbfastr.R`.
  * *FCS Opponents:* Non-conference FCS games automatically resolve to `tier = NULL` and are excluded from training statistics without breaking foreign keys.

---

## Model Selection & Architecture Tradeoffs

Sequence models were chosen over full Transformers due to the sample size inherent to college football (~15–20k sequences across 10–12 seasons, each ~13–16 steps long). 

### Priority Order (`04_model_comparison.R`)
1. **GRU (Primary):** Provides the optimal balance of sample efficiency and capacity for ~13–16 step weekly sequences.
2. **LSTM (Bake-Off Baseline):** Evaluates if separate cell state tracking improves late-season trajectory modeling, tested natively via `torch::nn_lstm`.
3. **Transformer (Benchmark Only):** Small encoder included as a control baseline; unlikely to outperform recurrent architectures given short sequence lengths.
4. **XGBoost & Elo-Logit:** Always-on tabular baselines providing cheap, robust weekly benchmarks.

---

## Feature Engineering & Methodology

### Atomic Play Grain
All rate metrics (YPP, EPA/play, success rate, explosiveness) are derived directly from individual snaps in `cfbd_pbp_data()` rather than pre-aggregated box scores. This normalizes team pace (e.g., 60-play vs. 100-play teams). Both raw and garbage-time-excluded metrics are calculated side-by-side.

### Sample-Size Thresholding ($\ge 320$ Plays)
Rate statistics carry higher variance early in the season. The pipeline tracks `cumulative_plays_to_date` and evaluates model performance across sample buckets (0–1, 1–2, 2–3, 3–4, and 4+ games, assuming ~80 plays/game).

### Prediction Confidence & Error Intervals
Upcoming games are classified into confidence tiers based on the lower-sampled team's play history:
* **Low:** $< 160$ plays
* **Medium:** $160–319$ plays
* **High:** $\ge 320$ plays (`MIN_SAMPLE_PLAYS`)

Prediction interval bounds (`predicted_spread_low` / `predicted_spread_high`) are dynamically populated using the champion model's historical RMSE within that specific sample-size bucket.

---

## Model Validation & Evaluation

* **Validation Strategy:** Walk-forward validation by season (training strictly on seasons $< N$). Random $k$-fold cross-validation is explicitly forbidden to prevent temporal leakage.
* **Evaluation Metrics:** Spread RMSE/MAE against actual margin; Win-Probability Log Loss and Brier Score for calibration.
* **Target Benchmark:** Closing Vegas Consensus Line (beating a 50% coin-flip is trivial; beating market efficiency is the objective).
* **Champion Selection Rule:** Lowest spread RMSE across the last 3 held-out seasons, subject to Log Loss $\le$ Elo-Logit baseline.

---

## Project Structure

| File | Purpose |
|---|---|
| `sql/schema.sql` | PostgreSQL DDL (teams, games, per-game stats, ratings, betting lines, predictions) |
| `R/01_ingest_cfbfastr.R` | Pulls and upserts schedules, box scores, advanced metrics, and betting lines |
| `R/02_eda.R` | Missingness reports, HFA estimation, predictor correlation, and ADF stationarity tests |
| `R/03_feature_engineering.R` | Generates leakage-safe tabular features and ordered team sequences |
| `R/04_model_comparison.R` | Executes walk-forward bake-off across all 5 candidate model architectures |
| `R/05_predict_and_compare.R` | Generates weekly pairwise predictions and comparison reports vs. market lines |
| `cron/crontab_cfb2026.txt` | Cron schedule for automated nightly data ingestion and weekly inference |

---

## Environment Setup & Execution

1. **Database & API Setup:** Provision PostgreSQL, execute `sql/schema.sql`, and configure environment variables (`PGHOST`, `PGDATABASE`, `CFBD_API_KEY`).
2. **Historical Ingestion:** Run `R/01_ingest_cfbfastr.R` across historical seasons (e.g., 2015–2026) to populate training data.
3. **Feature Generation & Bake-Off:** Execute `03_feature_engineering.R` followed by `04_model_comparison.R` to select the champion model.
4. **Weekly Inference:** Execute `05_predict_and_compare.R` to output weekly predictions to PostgreSQL and `week{N}_comparison.csv`.

```
