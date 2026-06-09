using CustomerPortalService as service from '../../srv/customerportal-service';

// ── List Page: columns ────────────────────────────────────────────
annotate service.Customers with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: customerNumber, Label: 'Customer #'     },
    { $Type: 'UI.DataField', Value: companyName,    Label: 'Company Name'   },
    { $Type: 'UI.DataField', Value: segmentName,    Label: 'Segment'        },
    { $Type: 'UI.DataField', Value: industryName,   Label: 'Industry'       },
    { $Type: 'UI.DataField', Value: city,           Label: 'City'           },
    { $Type: 'UI.DataField', Value: country,        Label: 'Country'        },
    { $Type: 'UI.DataField', Value: annualRevenue,  Label: 'Annual Revenue' },
    { $Type: 'UI.DataField', Value: isActive,       Label: 'Active'         }
  ]
);

// ── List Page: Search filters ─────────────────────────────────────
annotate service.Customers with @(
  UI.SelectionFields: [ segment_code, industry_code, isActive ]
);

// ── Detail Page: Header ───────────────────────────────────────────
annotate service.Customers with @(
  UI.HeaderInfo: {
    TypeName:       'Customer',
    TypeNamePlural: 'Customers',
    Title:          { Value: companyName },
    Description:    { Value: customerNumber }
  }
);

// ── Detail Page: Header fields ────────────────────────────────────
annotate service.Customers with @(
  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Header' }
  ],
  UI.FieldGroup#Header: {
    Data: [
      { Value: segmentName,   Label: 'Segment'   },
      { Value: industryName,  Label: 'Industry'  },
      { Value: city,          Label: 'City'      },
      { Value: country,       Label: 'Country'   },
      { Value: website,       Label: 'Website'   },
      { Value: annualRevenue, Label: 'Revenue'   },
      { Value: rating,        Label: 'Rating'    },
      { Value: isActive,      Label: 'Active'    }
    ]
  }
);

// ── Detail Page: Tabs ─────────────────────────────────────────────
annotate service.Customers with @(
  UI.Facets: [
    {
      $Type:  'UI.ReferenceFacet',
      Label:  'General Information',
      Target: '@UI.FieldGroup#General'
    },
    {
      $Type:  'UI.ReferenceFacet',
      Label:  'Contacts',
      Target: 'contacts/@UI.LineItem'
    },
    {
      $Type:  'UI.ReferenceFacet',
      Label:  'Service Tickets',
      Target: 'tickets/@UI.LineItem'
    },
    {
      $Type:  'UI.ReferenceFacet',
      Label:  'Opportunities',
      Target: 'opportunities/@UI.LineItem'
    },
    {
      $Type:  'UI.ReferenceFacet',
      Label:  'Sales Orders',
      Target: 'salesOrders/@UI.LineItem'
    }
  ],
  UI.FieldGroup#General: {
    Data: [
      { Value: customerNumber, Label: 'Customer Number' },
      { Value: companyName,    Label: 'Company Name'   },
      { Value: segmentName,    Label: 'Segment'        },
      { Value: industryName,   Label: 'Industry'       },
      { Value: website,        Label: 'Website'        },
      { Value: annualRevenue,  Label: 'Annual Revenue' },
      { Value: employeeCount,  Label: 'Employees'      },
      { Value: rating,         Label: 'Rating'         },
      { Value: npsScore,       Label: 'NPS Score'      },
      { Value: street,         Label: 'Street'         },
      { Value: city,           Label: 'City'           },
      { Value: state,          Label: 'State'          },
      { Value: postalCode,     Label: 'Postal Code'    },
      { Value: country,        Label: 'Country'        }
    ]
  }
);

// ── Contacts tab ──────────────────────────────────────────────────
annotate service.Contacts with @(
  UI.LineItem: [
    { Value: fullName,        Label: 'Name'           },
    { Value: roleName,        Label: 'Role'           },
    { Value: department,      Label: 'Department'     },
    { Value: email,           Label: 'Email'          },
    { Value: phone,           Label: 'Phone'          },
    { Value: isPrimary,       Label: 'Primary'        },
    { Value: isDecisionMaker, Label: 'Decision Maker' }
  ]
);

// ── Service Tickets tab ───────────────────────────────────────────
annotate service.ServiceTickets with @(
  UI.LineItem: [
    { Value: ticketNumber, Label: 'Ticket #'    },
    { Value: title,        Label: 'Title'       },
    { Value: priorityName, Label: 'Priority'    },
    { Value: statusName,   Label: 'Status'      },
    { Value: assignedTo,   Label: 'Assigned To' },
    { Value: resolvedAt,   Label: 'Resolved At' }
  ]
);

// ── Opportunities tab ─────────────────────────────────────────────
annotate service.Opportunities with @(
  UI.LineItem: [
    { Value: opportunityNumber, Label: 'Opp #'         },
    { Value: title,             Label: 'Title'         },
    { Value: stageName,         Label: 'Stage'         },
    { Value: expectedRevenue,   Label: 'Revenue'       },
    { Value: probability,       Label: 'Probability %' },
    { Value: expectedCloseDate, Label: 'Close Date'    },
    { Value: assignedTo,        Label: 'Assigned To'   }
  ]
);

// ── Sales Orders tab ──────────────────────────────────────────────
annotate service.SalesOrders with @(
  UI.LineItem: [
    { Value: orderNumber,   Label: 'Order #'  },
    { Value: orderDate,     Label: 'Date'     },
    { Value: status,        Label: 'Status'   },
    { Value: netAmount,     Label: 'Amount'   },
    { Value: currency,      Label: 'Currency' },
    { Value: paymentStatus, Label: 'Payment'  }
  ]
);

// ── Segment value help (dropdown) ─────────────────────────────────
annotate service.Customers with {
  segment @(
    Common.Text: segmentName,
    Common.Text.$Type: 'Common.TextType/TextOnly',
    Common.ValueList: {
      CollectionPath: 'CustomerSegments',
      Parameters: [
        {
          $Type: 'Common.ValueListParameterOut',
          LocalDataProperty: segment_code,
          ValueListProperty: 'code'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name'
        }
      ]
    },
    Common.ValueListWithFixedValues: true
  );
  industry @(
    Common.Text: industryName,
    Common.Text.$Type: 'Common.TextType/TextOnly',
    Common.ValueList: {
      CollectionPath: 'IndustryTypes',
      Parameters: [
        {
          $Type: 'Common.ValueListParameterOut',
          LocalDataProperty: industry_code,
          ValueListProperty: 'code'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name'
        }
      ]
    },
    Common.ValueListWithFixedValues: true
  );
};

// ── Enable Create / Edit / Delete ─────────────────────────────────
annotate service.Customers with @(
  UI.CreateHidden: false,
  UI.UpdateHidden: false,
  UI.DeleteHidden: false,
  Capabilities: {
    InsertRestrictions: { Insertable: true },  
    UpdateRestrictions: { Updatable:  true },  
    DeleteRestrictions: { Deletable:  true }   
  }
);

annotate service.ServiceTickets with @(  
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable:  true },
    DeleteRestrictions: { Deletable:  true }
  }
);

annotate service.Opportunities with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable:  true },
    DeleteRestrictions: { Deletable:  true }
  }
);