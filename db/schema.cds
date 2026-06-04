namespace customerportal;


// These come from CAP's built-in library
// cuid      → auto UUID primary key on every entity
// managed   → auto createdAt, createdBy, modifiedAt, modifiedBy
// CodeList  → base for lookup/dropdown tables (has code + name)
using {
     cuid,
     managed,
     sap.common.CodeList
} from '@sap/cds/common';

// ── Reusable scalar types ─────────────────────────────────────────
// Instead of writing String(254) everywhere, we name it Email
type Email : String(254);
type Phone : String(30);
type Money : Decimal(15, 2);


//---------CODE List ------------------
// These become small lookup tables with a 'code' key and 'name'

entity CustomerSegments : CodeList {
     key code : String(10);
}
//// Rows will be: ENT=Enterprise, MID=Mid-Market, SMB=Small Business

entity IndustryTypes : CodeList {
     key code : String(10);
}
//Rows will be: TECH=Technology, FIN=Financial Services, MFG=Manufacturing

entity ContactRoles : CodeList {
     key code : String(10);
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


//Customer Master

entity Customers : cuid, managed {
     customerNumber : String(20);
     companyName    : String(100);
     segment        : Association to CustomerSegments;
     industry       : Association to IndustryTypes;

     //Contact Information
     website        : String(500);
     annualRevenue  : Money;
     employeeCount  : Integer;
     rating         : Integer; // 1-5 stars
     npsScore       : Integer; // -100 to +100
     isActive       : Boolean;

     //Address
     street         : String(200);
     city           : String(100);
     state          : String(100);
     postalCode     : String(20);
     country        : String(100);


     // ── Compositions: Customer OWNS these child records ───────────
     // Deleting a customer cascades to all of these

     contacts       : Composition of many Contacts
                           on contacts.customer = $self;
     activities     : Composition of many Activities
                           on activities.customer = $self;
     tickets        : Composition of many ServiceTickets
                           on tickets.customer = $self;

     opportunities  : Composition of many Opportunities
                           on opportunities.customer = $self;

     salesOrders    : Composition of many SalesOrders
                           on salesOrders.customer = $self;

}


// ── Contacts ─────────────────────────────────────────────────────
entity Contacts : cuid, managed {
  customer        : Association to Customers;   // belongs to one customer
  firstName       : String(100) @mandatory;
  lastName        : String(100) @mandatory;
  fullName        : String(201);                // computed in handler
  role            : Association to ContactRoles;
  department      : String(100);
  email           : Email;
  phone           : Phone;
  isPrimary       : Boolean default false;
  isDecisionMaker : Boolean default false;
}


// ── Activities (interaction history) ─────────────────────────────
entity Activities : cuid, managed {
  customer        : Association to Customers;
  contact         : Association to Contacts;    // which contact was involved
  subject         : String(500) @mandatory;
  description     : String(5000);
  scheduledAt     : DateTime;
  isCompleted     : Boolean default false;
  channel         : String(50);   // email / call / meeting / demo
  sentiment       : String(20);   // positive / neutral / negative
  assignedTo      : String(100);  // employee email
}


// ── Service Tickets ───────────────────────────────────────────────
entity ServiceTickets : cuid, managed {
  customer     : Association to Customers;
  contact      : Association to Contacts;
  ticketNumber : String(20);          // TKT-000001 (auto-generated in handler)
  title        : String(500) @mandatory;
  description  : String(5000);
  priority     : Association to TicketPriorities;  // CRIT/HIGH/MED/LOW
  status       : Association to TicketStatuses;    // NEW/OPEN/RESOLVED/CLOSED
  assignedTo   : String(100);
  resolvedAt   : DateTime;
  resolution   : String(5000);

  // Ticket owns its comments
  comments     : Composition of many TicketComments
                   on comments.ticket = $self;
}

entity TicketComments : cuid, managed {
  ticket          : Association to ServiceTickets;
  text            : String(5000) @mandatory;
  isInternal      : Boolean default false;  // internal note vs customer reply
  author          : String(100);
}
// ── Opportunities ─────────────────────────────────────────────────
entity Opportunities : cuid, managed {
  customer          : Association to Customers;
  contact           : Association to Contacts;
  opportunityNumber : String(20);    // OPP-000001
  title             : String(500) @mandatory;
  stage             : Association to OpportunityStages;
  expectedRevenue   : Money;
  probability       : Decimal(5,2);  // 0–100 %
  expectedCloseDate : Date;
  lostReason        : String(500);
  assignedTo        : String(100);
}

// ── Sales Orders ──────────────────────────────────────────────────
entity SalesOrders : cuid, managed {
  customer      : Association to Customers;
  orderNumber   : String(30) @mandatory;
  status        : String(30);         // Processing / Delivered / Cancelled
  orderDate     : Date;
  netAmount     : Money;
  currency      : String(3) default 'USD';
  paymentStatus : String(30);         // Paid / Pending / Overdue

  // Order owns its line items
  items         : Composition of many SalesOrderItems
                    on items.order = $self;
}

entity SalesOrderItems : cuid {
  order         : Association to SalesOrders;
  productName   : String(200);
  quantity      : Decimal(10,2);
  unitPrice     : Money;
  totalPrice    : Money;
}