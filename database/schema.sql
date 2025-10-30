-- Supabase Database Schema for The Roofing App
-- Run this in Supabase SQL Editor to create all required tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Customer Types
CREATE TABLE IF NOT EXISTS customer_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers
CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    customer_type_id INTEGER REFERENCES customer_type(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Services/Products
CREATE TABLE IF NOT EXISTS service (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    unit VARCHAR(50) DEFAULT 'each',
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quote Status
CREATE TABLE IF NOT EXISTS quote_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#6B7280', -- Hex color for UI
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quotes
CREATE TABLE IF NOT EXISTS quote (
    id SERIAL PRIMARY KEY,
    quote_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    status_id INTEGER REFERENCES quote_status(id) DEFAULT 2, -- Default to 'Pending'
    title VARCHAR(200),
    description TEXT,
    subtotal DECIMAL(12,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,4) DEFAULT 0.0000,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    valid_until DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quote Line Items
CREATE TABLE IF NOT EXISTS quote_line_item (
    id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES quote(quote_number) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service(id),
    description VARCHAR(300) NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 1.00,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    line_total DECIMAL(12,2) DEFAULT 0.00,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quote Request Status
CREATE TABLE IF NOT EXISTS quote_request_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#6B7280',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quote Requests (from website leads)
CREATE TABLE IF NOT EXISTS quote_request (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    service_requested TEXT,
    message TEXT,
    status_id INTEGER REFERENCES quote_request_status(id) DEFAULT 1, -- Default to 'New'
    customer_id INTEGER REFERENCES customer(id), -- Link to customer once converted
    quote_id INTEGER REFERENCES quote(id), -- Link to quote once created
    source VARCHAR(100) DEFAULT 'website',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Invoice Status
CREATE TABLE IF NOT EXISTS invoice_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#6B7280',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Invoices
CREATE TABLE IF NOT EXISTS invoice (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    quote_id INTEGER REFERENCES quote(id), -- Optional link to original quote
    invoice_status_id INTEGER REFERENCES invoice_status(id) DEFAULT 2, -- Default to 'Pending'
    title VARCHAR(200),
    description TEXT,
    subtotal DECIMAL(12,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,4) DEFAULT 0.0000,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    amount_paid DECIMAL(12,2) DEFAULT 0.00,
    balance_due DECIMAL(12,2) DEFAULT 0.00,
    issue_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Invoice Line Services
CREATE TABLE IF NOT EXISTS invoice_line_service (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoice(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service(id),
    description VARCHAR(300) NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 1.00,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    line_total DECIMAL(12,2) DEFAULT 0.00,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Invoice Payments
CREATE TABLE IF NOT EXISTS invoice_payment (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoice(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50), -- 'cash', 'check', 'credit_card', 'bank_transfer', etc.
    payment_date DATE DEFAULT CURRENT_DATE,
    reference_number VARCHAR(100), -- Check number, transaction ID, etc.
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects/Jobs
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    quote_id INTEGER REFERENCES quote(id),
    invoice_id INTEGER REFERENCES invoice(id),
    status VARCHAR(50) DEFAULT 'planning', -- 'planning', 'in_progress', 'completed', 'cancelled'
    start_date DATE,
    end_date DATE,
    estimated_hours DECIMAL(8,2),
    actual_hours DECIMAL(8,2),
    description TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default data
INSERT INTO customer_type (name, description) VALUES
('Residential', 'Homeowners and residential properties'),
('Commercial', 'Business and commercial properties'),
('Insurance', 'Insurance claim work'),
('Property Management', 'Property management companies')
ON CONFLICT (name) DO NOTHING;

INSERT INTO quote_status (id, name, description, color) VALUES
(1, 'Accepted', 'Quote has been accepted by customer', '#10B981'),
(2, 'Pending', 'Awaiting customer response', '#F59E0B'),
(3, 'Rejected', 'Quote was declined by customer', '#EF4444'),
(4, 'Expired', 'Quote has expired', '#6B7280')
ON CONFLICT (name) DO NOTHING;

INSERT INTO quote_request_status (id, name, description, color) VALUES
(1, 'New', 'New lead from website', '#3B82F6'),
(2, 'Contacted', 'Customer has been contacted', '#F59E0B'),
(3, 'Quoted', 'Quote has been sent', '#8B5CF6'),
(4, 'Converted', 'Converted to customer/job', '#10B981'),
(5, 'Lost', 'Lead did not convert', '#EF4444')
ON CONFLICT (name) DO NOTHING;

INSERT INTO invoice_status (id, name, description, color) VALUES
(1, 'Paid', 'Invoice has been paid in full', '#10B981'),
(2, 'Pending', 'Invoice sent, awaiting payment', '#F59E0B'),
(3, 'Overdue', 'Invoice is past due date', '#EF4444'),
(4, 'Cancelled', 'Invoice has been cancelled', '#6B7280')
ON CONFLICT (name) DO NOTHING;

-- Sample services
INSERT INTO service (name, description, unit_price, unit, category) VALUES
('Roof Inspection', 'Comprehensive roof inspection and assessment', 150.00, 'each', 'Inspection'),
('Asphalt Shingle Installation', 'Installation of asphalt shingles', 5.50, 'sq ft', 'Installation'),
('Gutter Cleaning', 'Clean and clear gutters and downspouts', 125.00, 'linear ft', 'Maintenance'),
('Emergency Roof Repair', 'Emergency roof leak repair', 85.00, 'hour', 'Repair'),
('Metal Roofing Installation', 'Installation of metal roofing system', 12.00, 'sq ft', 'Installation'),
('Chimney Repair', 'Chimney maintenance and repair', 75.00, 'hour', 'Repair')
ON CONFLICT (name) DO NOTHING;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_customer_email ON customer(email);
CREATE INDEX IF NOT EXISTS idx_customer_type ON customer(customer_type_id);
CREATE INDEX IF NOT EXISTS idx_quote_customer ON quote(customer_id);
CREATE INDEX IF NOT EXISTS idx_quote_status ON quote(status_id);
CREATE INDEX IF NOT EXISTS idx_quote_number ON quote(quote_number);
CREATE INDEX IF NOT EXISTS idx_invoice_customer ON invoice(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoice_status ON invoice(invoice_status_id);
CREATE INDEX IF NOT EXISTS idx_invoice_number ON invoice(invoice_number);
CREATE INDEX IF NOT EXISTS idx_quote_request_status ON quote_request(status_id);
CREATE INDEX IF NOT EXISTS idx_quote_request_email ON quote_request(email);
CREATE INDEX IF NOT EXISTS idx_projects_customer ON projects(customer_id);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_customer_updated_at BEFORE UPDATE ON customer FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quote_updated_at BEFORE UPDATE ON quote FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quote_request_updated_at BEFORE UPDATE ON quote_request FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoice_updated_at BEFORE UPDATE ON invoice FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) - Enable after setting up auth
-- Uncomment these after configuring authentication users/roles
-- ALTER TABLE customer ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE quote ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE invoice ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE quote_request ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE projects ENABLE ROW LEVEL SECURITY;