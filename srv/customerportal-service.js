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
        );
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
        });


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

        });

        // Befor create and Update : Contact Full Name 
        this.before(['CREATE', 'UPDATE'], Contacts, async (req) => {
            let firstName = req.data.firstName;
            let lastName = req.data.lastName;

            if (firstName && lastName) {
                if (!firstName) firstName = ' ';
                if (!lastName) lastName = ' ';
                req.data.fullName = (firstName + ' ' + lastName).trim();

            }

        });

        // Action Escalate
        this.on('escalate', ServiceTickets, async (req) => {
            const { ID } = req.params[0];
            const { reason } = req.data;

            await UPDATE(ServiceTickets).set({ status_code: 'ESCALATED' }).where({ ID: ID });

            await INSERT.into(TicketComments).entries({
                ticket_ID: ID,
                text: `Ticket escalated. Reason: ${reason}`,
                isInternal: true,
                author: req.user?.id || 'system'
            })

            return SELECT.one(ServiceTickets).where({ ID });
        });
        // Action Resolve
        this.on('resolveTicket', ServiceTickets, async (req) => {

            const { ID } = req.params[0];
            const { resolution } = req.data;


            await UPDATE(ServiceTickets).set({
                status_code: 'RESOLVED',
                resolution: resolution,
                resolvedAt: new Date().toISOString()

            }).where({ ID: ID });


            return SELECT.one(ServiceTickets).where({ ID });

        });

        this.on('close', ServiceTickets, async (req) => {
            const { ID } = req.params[0];

            await UPDATE(ServiceTickets)
                .set({ status_code: 'CLOSED' })
                .where({ ID });

            return SELECT.one(ServiceTickets).where({ ID });
        });
        // ── ACTION: markWon ────────────────────────────────────────
        this.on('markWon', Opportunities, async (req) => {
            const { ID } = req.params[0];
            const { actualRevenue } = req.data;

            await UPDATE(Opportunities)
                .set({
                    stage_code: 'CLOSE_WON',
                    expectedRevenue: actualRevenue,
                    expectedCloseDate: new Date().toISOString().split('T')[0]
                })
                .where({ ID });

            return SELECT.one(Opportunities).where({ ID });
        });

        // ── ACTION: markLost ───────────────────────────────────────
        this.on('markLost', Opportunities, async (req) => {
            const { ID } = req.params[0];
            const { reason } = req.data;

            await UPDATE(Opportunities)
                .set({
                    stage_code: 'CLOSE_LOST',
                    lostReason: reason,
                    expectedCloseDate: new Date().toISOString().split('T')[0]
                })
                .where({ ID });

            return SELECT.one(Opportunities).where({ ID });
        });

        this.on('activate', Customers, async (req) => {
            const { ID } = req.params[0];

            await UPDATE(Customers).set({ isActive: true }).where({ ID });

            return SELECT.one(Customers).where({ ID });
        });

        this.on('deactivate', Customers, async (req) => {
            const { ID } = req.params[0];

            await UPDATE(Customers).set({ isActive: false }).where({ ID });

            return SELECT.one(Customers).where({ ID });

        });

        // Dashboard Function Status
        this.on('getDashboardStat', async (req) => {

            const totalResults = await SELECT.one`count(*) as total`.from(Customers);
            const activeResults = await SELECT.one`count(*) as active`.from(Customers).where({ isActive: true });
            const inactiveResults = await SELECT.one`count(*) as inactive`.from(Customers).where({ isActive: false });
            const ticketResults = await SELECT.one`count(*) as cnt`.from(ServiceTickets).where({ status_code: { '!=': 'CLOSED' } });
            const opportunityResults = await SELECT.one`count(*)as cnt`.from(Opportunities).where({ stage_code: { '!=': 'CLOSE_WON' } })

            return {
                totalCustomers: totalResults.total || 0,
                activeCustomers: activeResults.active || 0,
                inactiveCustomers: inactiveResults.inactive || 0,
                openTickets: ticketResults.cnt || 0,
                openOpportunities: opportunityResults.cnt || 0
            };
        });



        this.on('searchCustomers', async (req) => {
            const { query, segment, industry } = req.data;

            let customers = SELECT.from(Customers);

            if (query) {
                customers = customers.where(`companyName like '%${query}%'`);
            }
            if (segment) {
                customers = customers.where({ segment_code: segment });
            }
            if (industry) {
                customers = customers.where({ industry_code: industry });
            }

            return customers.limit(50);
        })



        // Always call super.init() at the end
        await super.init()
    }




}