namespace  customerportal;


// These come from CAP's built-in library
// cuid      → auto UUID primary key on every entity
// managed   → auto createdAt, createdBy, modifiedAt, modifiedBy
// CodeList  → base for lookup/dropdown tables (has code + name)
using { cuid, managed , sap.common.Codelist} from '@sap/cds/common';

// ── Reusable scalar types ─────────────────────────────────────────
// Instead of writing String(254) everywhere, we name it Email
type Email : String(254);
type Phone : String(30);
type Money : Decimal(15,2);
