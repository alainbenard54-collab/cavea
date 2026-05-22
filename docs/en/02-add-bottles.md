# ➕ Add bottles

Add bottles in bulk via the add form: fill in common fields, set the total quantity, and distribute across multiple locations.

## Prerequisites

- App open in write mode (Local mode, or 🔄 Shared mode with the lock)

## Steps

### 1. Open the add form

Tap the **➕ Add** tab in the navigation.

> In 🔄 Shared read-only mode, this tab is greyed out (🔒) — you must close the other device holding the lock first.

### 2. Fill in common fields

These apply to all bottles in the batch.

**Identity section**

| Field | Required | Notes |
|---|---|---|
| Domain | **Yes** | Autocomplete on existing values |
| Appellation | **Yes** | Autocomplete |
| Vintage | **Yes** | Year number (e.g. 2019) |
| Colour | **Yes** | Reference list, configurable in ⚙️ Settings |
| Classification | No | Reference list, configurable |
| Volume | No | Default "75 cl" (configurable in ⚙️ Settings) |

**Ageing section**

| Field | Required | Notes |
|---|---|---|
| Ageing min | No | Number of years before optimum |
| Ageing max | No | Number of years until end of ageing |
| Purchase price | No | Per bottle |

**Supplier section**

| Field | Required | Notes |
|---|---|---|
| Supplier | No | Autocomplete |
| Supplier info | No | Address, contact, etc. |
| Producer | No | Autocomplete |

**Notes section**

| Field | Required | Notes |
|---|---|---|
| Entry note | No | Free comment at purchase |
| Entry date | No | Default: today |

### 3. Set the total quantity

Enter the total number of bottles to add in the **Total quantity** field.

### 4. Distribute across locations

The **Distribution** section lets you split the bottles across different areas of your cellar.

- Each group = `(quantity, location)`
- Location offers autocomplete on your existing locations
- The sum of quantities must **equal** the total quantity (real-time validation indicator shown)
- If all bottles go to the same place, keep a single group

**Location format**: `Level1` or `Level1 > Level2 > Level3`

Examples: `Cellar`, `Cellar > Racks > A1`, `Reserve`

### 5. Ageing validation

- If both `ageing_min` and `ageing_max` are filled in: `ageing_min ≤ ageing_max` is checked — an error appears otherwise and saving is blocked
- If either is missing: a dialog warns you that maturity cannot be calculated. Choose **Confirm without ageing** or **Back**

### 6. Save

Tap **Add N bottle(s)**. The app creates a separate row in the database for each physical bottle, each with a unique identifier.

## See also

- [03 — Browse stock](03-stock.md)
- [04 — Maturity](04-maturity.md)
- [13 — Settings](13-settings.md) (reference lists, default values)
