namespace  customerportal;


// These come from CAP's built-in library
// cuid      → auto UUID primary key on every entity
// managed   → auto createdAt, createdBy, modifiedAt, modifiedBy
// CodeList  → base for lookup/dropdown tables (has code + name)
using { cuid, managed , sap.common.CodeList} from '@sap/cds/common';

// ── Reusable scalar types ─────────────────────────────────────────
// Instead of writing String(254) everywhere, we name it Email
type Email : String(254);
type Phone : String(30);
type Money : Decimal(15,2);


//---------CODE List ------------------
// These become small lookup tables with a 'code' key and 'name'

entity CustomerSegments : CodeList {
     key code  : String(10);
}
//// Rows will be: ENT=Enterprise, MID=Mid-Market, SMB=Small Business

entity IndustryTypes : CodeList {
     key code  : String(10);
}
//Rows will be: TECH=Technology, FIN=Financial Services, MFG=Manufacturing

entity ContactRoles : CodeList {
        key code  : String(10);
}
// Rows: CEO, CTO, CFO, IT, PROC (Procurement) etc.

entity TicketPriorities : CodeList {
     key code : String(10);
}
// Rows: CRIT=Critical, HIGH=High, MED=Medium, LOW=Low
entity TicketStatuses : CodeList {
     key code : String(10);
}
// Rows: OPEN=Open, INPR=In Progress, RES=Resolved, CLSD
entity OpportunityStages : CodeList {
  key code : String(20);
}
// Rows: PROSPECT, QUALIFY, PROPOSE, CLOSE_WON, CLOSE_LOST