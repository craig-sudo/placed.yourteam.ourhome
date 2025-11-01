-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Customer Types
CREATE TABLE IF NOT EXISTS customer_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Customers
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    customer_type_id INTEGER REFERENCES customer_types(id),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(20) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    company_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Services
CREATE TABLE IF NOT EXISTS services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    default_price VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quote Request Status
CREATE TABLE IF NOT EXISTS quote_request_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quote Status
CREATE TABLE IF NOT EXISTS quote_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoice Status
CREATE TABLE IF NOT EXISTS invoice_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quote Requests
CREATE TABLE IF NOT EXISTS quote_requests (
    id SERIAL PRIMARY KEY,
    service_type_id INTEGER REFERENCES services(id),
    customer_typeID INTEGER REFERENCES customer_types(id),
    firstName VARCHAR(255) NOT NULL,
    lastName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    streetAddress VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(20) NOT NULL,
    custom_service TEXT,
    requested_date DATE NOT NULL,
    est_request_status_id INTEGER REFERENCES quote_request_status(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quotes
CREATE TABLE IF NOT EXISTS quotes (
    id SERIAL PRIMARY KEY,
    quote_number INTEGER NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES customers(id),
    status_id INTEGER REFERENCES quote_status(id),
    service_id INTEGER REFERENCES services(id),
    issue_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    quote_date DATE NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    invoiced_total DECIMAL(10,2) DEFAULT 0,
    note TEXT,
    measurement_note TEXT,
    cust_note TEXT,
    custom_street_address VARCHAR(255),
    custom_city VARCHAR(255),
    custom_state VARCHAR(50),
    custom_zipcode VARCHAR(20),
    custom_address BOOLEAN DEFAULT FALSE,
    converted BOOLEAN DEFAULT FALSE,
    private_note TEXT,
    public_note TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Quote Line Items
CREATE TABLE IF NOT EXISTS quote_line_items (
    id SERIAL PRIMARY KEY,
    quote_id INTEGER REFERENCES quotes(id),
    service_id INTEGER REFERENCES services(id),
    qty INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    rate DECIMAL(10,2) NOT NULL,
    sq_ft DECIMAL(10,2) NOT NULL,
    description TEXT,
    fixed_item BOOLEAN DEFAULT FALSE,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    invoice_number INTEGER NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES customers(id),
    service_type_id INTEGER REFERENCES services(id),
    invoice_status_id INTEGER REFERENCES invoice_status(id),
    invoice_date DATE NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    sqft_measurement VARCHAR(255),
    note TEXT,
    bill_from_street_address VARCHAR(255) NOT NULL,
    bill_from_city VARCHAR(255) NOT NULL,
    bill_from_state VARCHAR(50) NOT NULL,
    bill_from_zipcode VARCHAR(20) NOT NULL,
    bill_from_email VARCHAR(255) NOT NULL,
    bill_to_street_address VARCHAR(255) NOT NULL,
    bill_to_city VARCHAR(255) NOT NULL,
    bill_to_state VARCHAR(50) NOT NULL,
    bill_to_zipcode VARCHAR(20) NOT NULL,
    cust_note TEXT,
    amount_due DECIMAL(10,2) NOT NULL,
    bill_to BOOLEAN DEFAULT FALSE,
    converted_from_quote_number INTEGER REFERENCES quotes(quote_number),
    private_note TEXT,
    public_note TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoice Line Services
CREATE TABLE IF NOT EXISTS invoice_line_services (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id),
    service_id INTEGER REFERENCES services(id),
    sq_ft DECIMAL(10,2) NOT NULL,
    qty INTEGER NOT NULL,
    rate DECIMAL(10,2) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    fixed_item BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoice Payments
CREATE TABLE IF NOT EXISTS invoice_payments (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id),
    payment_method VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date_received DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Projects (Under Development)
CREATE TABLE IF NOT EXISTS projects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_number INTEGER NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    service INTEGER REFERENCES services(id),
    customer INTEGER REFERENCES customers(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Insert default customer types
INSERT INTO customer_types (name, description) VALUES
    ('Residential', 'Individual homeowners and residential properties'),
    ('Commercial', 'Business and commercial properties'),
    ('Industrial', 'Industrial and manufacturing facilities'),
    ('Multi-Family/HOA', 'Multi-family housing and homeowners associations'),
    ('Government/Institutional', 'Government and institutional buildings')
ON CONFLICT (name) DO NOTHING;

-- Insert default quote request statuses
INSERT INTO quote_request_status (name, description) VALUES
    ('New', 'New quote request'),
    ('In Progress', 'Quote being prepared'),
    ('Completed', 'Quote has been sent'),
    ('Cancelled', 'Quote request cancelled')
ON CONFLICT (name) DO NOTHING;

-- Insert default quote statuses
INSERT INTO quote_status (name, description) VALUES
    ('Draft', 'Quote is being prepared'),
    ('Sent', 'Quote has been sent to customer'),
    ('Accepted', 'Quote has been accepted by customer'),
    ('Rejected', 'Quote has been rejected by customer'),
    ('Expired', 'Quote has expired'),
    ('Converted', 'Quote has been converted to invoice')
ON CONFLICT (name) DO NOTHING;

-- Insert default invoice statuses
INSERT INTO invoice_status (name, description) VALUES
    ('Draft', 'Invoice is being prepared'),
    ('Sent', 'Invoice has been sent to customer'),
    ('Partial Payment', 'Partial payment received'),
    ('Paid', 'Invoice has been fully paid'),
    ('Overdue', 'Payment is overdue'),
    ('Void', 'Invoice has been voided')
ON CONFLICT (name) DO NOTHING;

-- Insert default services
INSERT INTO services (name, description, default_price) VALUES
    ('Inspection', 'Detailed inspection of property', '$150 per inspection'),
    ('Maintenance', 'General maintenance and repairs', '$100 per hour'),
    ('Emergency Service', 'Emergency response and repairs', '$200 per hour'),
    ('Consultation', 'Professional consultation', '$125 per hour')
ON CONFLICT (name) DO NOTHING;