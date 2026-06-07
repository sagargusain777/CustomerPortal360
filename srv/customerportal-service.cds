using {customerportal as db} from '../db/schema';


service CustomerPortalService {

  entity Contacts          as
    projection on db.Contacts {
      *,
      role.name            as roleName,
      customer.companyName as customerName
    };

  entity Activities        as
    projection on db.Activities {
      *,
      customer.companyName as customerName,
      contact.firstName    as contactFirstName,
      contact.lastName     as contactLastName
    };

  entity TicketComments    as projection on db.TicketComments;

  entity ServiceTickets    as
    projection on db.ServiceTickets {
      *,
      priority.name        as priorityName,
      status.name          as statusName,
      customer.companyName as customerName,
      comments : redirected to TicketComments
    };

  entity Opportunities     as
    projection on db.Opportunities {
      *,
      stage.name           as stageName,
      customer.companyName as customerName,
      contact.firstName    as contactFirstName,
      contact.lastName     as contactLastName
    };

  entity SalesOrderItems   as projection on db.SalesOrderItems;

  entity SalesOrders       as
    projection on db.SalesOrders {
      *,
      customer.companyName as customerName,
      items : redirected to SalesOrderItems
    };

  // ── Customers LAST (uses all entities above) ─────────────────
  @odata.draft.enabled
  entity Customers         as
    projection on db.Customers {
      *,
      segment.name  as segmentName,
      industry.name as industryName,
      contacts      : redirected to Contacts,
      activities    : redirected to Activities,
      tickets       : redirected to ServiceTickets,
      opportunities : redirected to Opportunities,
      salesOrders   : redirected to SalesOrders
    };

  // ── Code Lists (read-only) ───────────────────────────────────
  @readonly
  entity CustomerSegments  as projection on db.CustomerSegments;

  @readonly
  entity IndustryTypes     as projection on db.IndustryTypes;

  @readonly
  entity ContactRoles      as projection on db.ContactRoles;

  @readonly
  entity TicketPriorities  as projection on db.TicketPriorities;

  @readonly
  entity TicketStatuses    as projection on db.TicketStatuses;

  @readonly
  entity OpportunityStages as projection on db.OpportunityStages;

  //Ticket Actions
  extend projection ServiceTickets with actions {
    action escalate(reason: String(500))    returns ServiceTickets;
    action resolveTicket(resolution: String(500)) returns ServiceTickets;
    action close()                          returns ServiceTickets;
  }

  // Opportunity Actions
  extend projection Opportunities with actions {

    action markWon(actualRevenue: Decimal(15, 2)) returns Opportunities;
    action markLost(reason: String(500))          returns Opportunities;
  }
  //Cutomer  Actions

  extend projection Customers with actions {
    action activate()   returns Customers;
    action deactivate() returns Customers;
  }

  // Unbound functions 
  function getDashboardStat() returns{
    totalCustomers    : Integer;
    activeCustomers   : Integer;
    inactiveCustomers : Integer;
    openTickets       : Integer;
    openOpportunities : Integer;
  } ;

  function searchCustomers(
    query    : String(200),
    segment  : String(10),
    industry : String(10)
  ) returns array of Customers;

}
