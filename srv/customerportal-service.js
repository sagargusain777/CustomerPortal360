

const cds = require('@sap/cds');

module.exports = class CustomerPortalService extends cds.ApplicationService {

    async init() {
        const { Customers, Contacts,
            Activities,
            ServiceTickets,
            TicketComments,
            Opportunities,
            SalesOrders } = this.entities;




        // Always call super.init() at the end
        await super.init()
    }


}