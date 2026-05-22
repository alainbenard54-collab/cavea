# 🍷 Maturity

Understand maturity levels, use the maturity filter, and sort bottles by urgency.

## How maturity is calculated

Maturity is calculated automatically at display time, from the vintage and the ageing values:

| Condition | Level | Colour |
|---|---|---|
| `current_year < vintage + ageing_min` | Too young | 🔵 Blue |
| `vintage + ageing_min ≤ current_year ≤ vintage + ageing_max` | Optimal | 🟢 Green |
| `current_year > vintage + ageing_max` | Drink now | 🔴 Red |
| ageing_min or ageing_max missing | No data | ⚫ Grey |

Examples with vintage 2015, ageing_min 5, ageing_max 10:
- In 2019 → 🔵 Too young (2020 is the first optimal year)
- In 2022 → 🟢 Optimal
- In 2026 → 🔴 Drink now

> **ageing_min = 0** is a valid value: the bottle is drinkable from the vintage year.

## Filter by maturity

In the **🍷 Stock** view, use the **Maturity** filter (multi-select) to show only the levels you want. Examples:
- Check 🟢 "Optimal" + 🔴 "Drink now" → bottles ready to drink now
- Check 🔵 "Too young" → bottles to keep longer

## Urgency sort

In the desktop table's **AGEING** column, the secondary urgency sort orders bottles by `(current_year - ageing_max)` descending — the most overdue appear first.

The AGEING column shows the year delta (e.g. `-3` = 3 years before optimum, `+2` = 2 years past the end of ageing).

## Bottles without ageing data

If ageing_min or ageing_max is not set, maturity shows ⚫ "No data". These bottles can be filtered or ignored.

## See also

- [02 — Add bottles](02-add-bottles.md) (entering ageing at add time)
- [03 — Browse stock](03-stock.md)
- [07 — Edit a bottle](07-edit-bottle.md) (correcting ageing on an existing bottle)
