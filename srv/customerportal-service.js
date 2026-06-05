'use strict';

const cds = require('@sap/cds');



module.exports = class CustomerPortalService extends cds.ApplicationService {

    async init() {
        const { Customers, Contacts,
            Activities,
            ServiceTickets,
            TicketComments,
            Opportunities,
            SalesOrders } = this.entities;



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



        // Always call super.init() at the end
        await super.init()
    }




}