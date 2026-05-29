# TH_Drugs

# Images For Inventory - https://drive.google.com/drive/folders/12Bn3XsJAf9CbXfKD5adH7e9Jq-bysKXW?usp=sharing

# Drug System

A comprehensive drug system for QBox featuring harvesting, processing, meth cooking in RVs, moonshine distilling, crack production, and XP-based progression.

## Requirements

- qbx_core
- ox_lib
- ox_inventory
- ox_target
- oxmysql
- cd_dispatch (for police alerts)
These Files Are Free
- bzzz_cocaplant - https://bzzz.tebex.io/package/5437764
- fury_stll - https://github.com/NukepugDesigns/Fury_still

## Installation

### 1. Database Setup

Execute the SQL file to create the required tables:

```sql
source sql/drugs_xp.sql
```

This creates `player_drug_xp` - Tracks player XP and level progression.

### 2. Item Registration

Add the items from `shared/items.lua` to your ox_inventory items.

### 3. Start Order

```lua
ensure qbx_core
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure oxmysql
ensure cd_dispatch
ensure drugs
```

---

## Drug Systems

### Weed

**Harvesting:**
- Find weed plants at harvest locations (Sandy Shores, Banham Canyon, Paleto Bay)
- Target the plant and select "Harvest Weed"
- Receive `weed_nug`

**Processing:**
- Go to a processing location with `weed_nug` and `baggies`
- Requires tools: `trimmers`, `grinder`, `scale` (not consumed)
- Process time: 30 seconds
- Output: `bagged_weed`

---

### Cocaine

**Harvesting:**
- Find coca plants at harvest locations (Raton Canyon, Chiliad, Sandy Shores)
- Target the plant and select "Harvest Coca Leaves"
- Receive `cocaine_leaf`

**Processing:**
- Go to a processing location with `cocaine_leaf` and `baggies`
- Requires tools: `trimmers`, `grinder`, `scale` (not consumed)
- Process time: 45 seconds
- Output: `cocaine`

---

### Meth Cooking (Mobile RV)

**Requirements:**
- Journey or Camper vehicle
- `pseudoephedrine`, `red_phosphorus`, `lithium_strips`

**How it works:**
1. Enter the back seat of a Journey or Camper
2. Press **E** to start cooking
3. Complete 40 skill checks (keys 1, 2, 3, 4)
4. Collect meth or fail and cause explosion

**Warning:** Failed cooking causes explosion and alerts police!

---

### Crack Processing

**Requirements:**
- `cocaine_powder` (5 per batch)
- `limestone_dust`

**Process:**
- Go to a crack processing location
- Target the zone and select "Process Crack"
- Process time: 45 seconds
- Output: 5-10 `crack`

---

### Moonshine Distilling

**Harvesting:**
- Grain: Harvest from farm sacks (Grain Fields)
- Sugar: Harvest from sugar cane plants
- Water: Collect from water barrels
- Yeast: Harvest from linen sacks

**Crafting:**
- Go to a Moonshine Still location
- Requires: 2 grain, 1 sugar, 2 water, 1 yeast
- Craft time: 2 minutes
- Output: 3-6 `shine`

---

## Drug Selling

### Requirements

- Minimum police on duty (configurable: `Config.Police.MinimumOnDuty`)
- Must have sellable drugs in inventory
- Must have reached the required XP level for the drug type

### How to Sell

1. Target any NPC with ox_target
2. Select "Offer Drugs" from the menu
3. Complete the transaction

### XP Level Requirements

| Level | XP Required | Can Sell |
|-------|-------------|----------|
| 1 | 0 | Weed |
| 2 | 100 | + Cocaine |
| 3 | 500 | + Meth |
| 4 | 1,500 | + Crack |
| 5 | 3,000 | + Moonshine |

### Police Alerts

All drug sales have a chance to alert police based on `Config.PoliceAlertChance`:
- Weed: 25%
- Cocaine: 35%
- Meth: 45%
- Crack: 40%
- Moonshine: 30%

Alerts go to all jobs defined in `Config.Police.Jobs` (default: police, bcso)

---

## Configuration

All settings in `config.lua`:

**Police Settings:**
- `Config.Police.Jobs` - Jobs that receive alerts
- `Config.Police.MinimumOnDuty` - Minimum cops required for selling

**Per-Drug Settings:**
- `Config.Weed` - Harvest zones, processing locations, times, ingredients
- `Config.Cocaine` - Harvest zones, processing locations, times, ingredients
- `Config.Meth` - Skill check settings, vehicle types, explosion damage
- `Config.Crack` - Processing locations, ingredients, batch amounts
- `Config.Moonshine` - Crafting locations, harvest zones, ingredients

**Prop Models:**
- `Config.Weed.HarvestProp` - Prop model for weed harvest zones
- `Config.Cocaine.HarvestProp` - Prop model for cocaine harvest zones
- `Config.Moonshine.HarvestZones[name].prop` - Prop per harvest type

**XP Settings:**
- `Config.XP.SellXP` - XP earned per drug sale
- `Config.XP.Levels` - Level thresholds and unlocks

---

## Exports

### Server Exports

```lua
exports['drugs']:GetPlayerDrugData(source)
exports['drugs']:AddDrugXP(source, amount, drugType)
exports['drugs']:CanSellDrug(source, drugType)
exports['drugs']:GetDrugLevel(source)
exports['drugs']:GetDrugXP(source)
exports['drugs']:GetDrugUnlocks(source)
```

---

## Items

### Weed Items
- `weed_nug` - Harvested from weed plants
- `bagged_weed` - Processed product (sellable)
- `baggies` - Consumed during processing
- `trimmers`, `grinder`, `scale` - Required tools

### Cocaine Items
- `cocaine_leaf` - Harvested from coca plants
- `cocaine` - Processed product (sellable)
- `cocaine_powder` - Used for crack production
- `limestone_dust` - Used for crack production

### Meth Items
- `pseudoephedrine`
- `red_phosphorus`
- `lithium_strips`
- `meth` - Final product (sellable)

### Moonshine Items
- `shinegrain`, `shinesugar`, `shinewater`, `shineyeast` - Ingredients
- `shine` - Final product (sellable)

### Crack Items
- `crack` - Final product (sellable)

---

## Troubleshooting

**Cannot see harvest props:**
- Check `Config.Debug` is enabled for spawn logs
- Verify prop model names are valid

**Cannot sell drugs:**
- Check police count meets minimum
- Verify player has drugs in inventory
- Verify player has reached required XP level

**Meth cooking not working:**
- Must be in back seat of Journey or Camper
- Must have all required items

**Processing not working:**
- Must have required ingredients and tools
- Tools are not consumed, ingredients are

