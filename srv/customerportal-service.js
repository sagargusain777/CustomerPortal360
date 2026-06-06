'use strict';

const cds = require('@sap/cds');
const { SELECT } = require('@sap/cds/lib/ql/cds-ql');



module.exports = class CustomerPortalService extends cds.ApplicationService {

    async init() {
        const { Customers, Contacts,
            Activities,
            ServiceTickets,
            TicketComments,
            Opportunities,
            SalesOrders } = this.entities;


        // Generate unique customer number before creating a new customer
        this.before('CREATE', Customers, async (req) => {

            const resultNumber = await SELECT.one`count(*) as cnt`.from(Customers);

            let currentCount = 0;

            if (resultNumber && resultNumber.cnt) {
                currentCount = parseInt(resultNumber.cnt);
            }

            let nextCustomerNumber = currentCount + 1;
            let paddedCustomerNumber = nextCustomerNumber.toString().padStart(6, '0');
            req.data.customerNumber = `CUST-${paddedCustomerNumber}`;
            req.data.isActive = true;
        }
        )
        // Generate unique ticket number before creating a new service ticket
        this.before('CREATE', ServiceTickets, async (req) => {
            const resultNumber = await SELECT.one`count(*)as cnt`.from(ServiceTickets);
            let currentCount = 0;
            if (resultNumber && resultNumber.cnt) {
                currentCount = parseInt(resultNumber.cnt);
            }

            let nextTicketNumber = currentCount + 1;
            let paddedTicketNumber = nextTicketNumber.toString().padStart(6, '0');
            req.data.ticketNumber = `TKT-${paddedTicketNumber}`;
            if (!req.data.status_code) req.data.status_code = 'NEW';
            if (!req.data.priority_code) req.data.priority_code = 'MED';
        })


        // Generate unique opportunity number before creating a new opportunity
        this.before('CREATE', Opportunities, async (req) => {

            const resultNumber = await SELECT.one`count(*) as cnt`.from(Opportunities);
            let currentCount = 0;
            if (resultNumber && resultNumber.cnt) {
                currentCount = parseInt(resultNumber.cnt);
            }

            let nextOpportunityNumber = currentCount + 1;
            let paddedOpportunityNumber = nextOpportunityNumber.toString().padStart(6, '0');
            req.data.opportunityNumber = `OPP-${paddedOpportunityNumber}`;

            if (!req.data.stage_code) req.data.stage_code = 'PROSPECT';

        } )

     // Befor create and Update : Contact Full Name 
     this.before(['CREATE', 'UPDATE'], Contacts , async (req) =>  {
        const { firstName, lastName} = req.data;
        if(!firstName || firstName === undefined){
            firstName = ' ';
        }

        if(!lastName || lastName === undefined){
            lastName = ' ';
        }

        req.data.fullName = `${firstName} ' ' ${lastName}`.trim();
        
     })

        // Always call super.init() at the end
        await super.init()
    }




}