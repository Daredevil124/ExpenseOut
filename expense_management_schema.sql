-- Odoo Expense Management System Database Schema
-- Based on the specific problem statement requirements

-- Companies (auto-created on first signup)
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    default_currency VARCHAR(3) DEFAULT 'USD',
    country_code VARCHAR(3),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users and Authentication
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_id VARCHAR(20),
    manager_id INTEGER,
    role VARCHAR(20) DEFAULT 'employee', -- employee, manager, admin
    is_manager_approver BOOLEAN DEFAULT false, -- IS MANAGER APPROVER field
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- Expense Categories (as per problem statement)
CREATE TABLE expense_categories (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    UNIQUE(company_id, code)
);

-- User Expense History (as per problem statement - employees can view their expense history)
CREATE TABLE user_expense_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    expense_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL, -- approved, rejected
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (expense_id) REFERENCES expenses(id)
);

-- Individual Expenses (as per problem statement requirements)
CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) NOT NULL, -- can be different from company's currency
    expense_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    current_approver_id INTEGER, -- current approver in the workflow
    current_step INTEGER DEFAULT 1, -- current step in sequential approval
    workflow_id INTEGER, -- assigned workflow
    is_manager_approval_required BOOLEAN DEFAULT true, -- IS MANAGER APPROVER field
    manager_approved BOOLEAN DEFAULT false,
    manager_approved_at TIMESTAMP,
    manager_comments TEXT,
    final_approved_by INTEGER,
    final_approved_at TIMESTAMP,
    rejected_by INTEGER,
    rejected_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES expense_categories(id),
    FOREIGN KEY (current_approver_id) REFERENCES users(id),
    FOREIGN KEY (workflow_id) REFERENCES approval_workflows(id),
    FOREIGN KEY (final_approved_by) REFERENCES users(id),
    FOREIGN KEY (rejected_by) REFERENCES users(id)
);

-- Approval Workflows (Sequential and Conditional)
CREATE TABLE approval_workflows (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    workflow_type VARCHAR(20) DEFAULT 'sequential', -- sequential, percentage, hybrid
    percentage_threshold INTEGER DEFAULT 100, -- for percentage-based approval
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- Approval Rules (Sequential Steps)
CREATE TABLE approval_rules (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL, -- Step 1, Step 2, Step 3, etc.
    approver_role VARCHAR(20), -- manager, finance, director, specific_user
    specific_approver_id INTEGER, -- for specific user assignments
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2),
    is_required BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workflow_id) REFERENCES approval_workflows(id),
    FOREIGN KEY (specific_approver_id) REFERENCES users(id)
);

-- Conditional Approval Rules (Percentage-based)
CREATE TABLE conditional_approval_rules (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER NOT NULL,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(20) NOT NULL, -- percentage, specific_approver, hybrid
    percentage_threshold INTEGER, -- e.g., 60% of approvers
    specific_approver_id INTEGER, -- e.g., CFO approval
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workflow_id) REFERENCES approval_workflows(id),
    FOREIGN KEY (specific_approver_id) REFERENCES users(id)
);

-- Expense Approvals (Sequential)
CREATE TABLE expense_approvals (
    id SERIAL PRIMARY KEY,
    expense_id INTEGER NOT NULL,
    approver_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL, -- pending, approved, rejected
    comments TEXT,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expenses(id),
    FOREIGN KEY (approver_id) REFERENCES users(id)
);

-- Conditional Approvals (Percentage-based)
CREATE TABLE conditional_approvals (
    id SERIAL PRIMARY KEY,
    expense_id INTEGER NOT NULL,
    approver_id INTEGER NOT NULL,
    rule_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL, -- pending, approved, rejected
    comments TEXT,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expenses(id),
    FOREIGN KEY (approver_id) REFERENCES users(id),
    FOREIGN KEY (rule_id) REFERENCES conditional_approval_rules(id)
);

-- Notifications (for approval requests and status updates)
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- expense_approval_request, expense_approved, expense_rejected
    related_expense_id INTEGER,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (related_expense_id) REFERENCES expenses(id)
);

-- System Settings (for company-specific configurations)
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    UNIQUE(company_id, setting_key)
);

-- Create indexes for better performance
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_manager_id ON users(manager_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_expenses_company_id ON expenses(company_id);
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_expenses_current_approver_id ON expenses(current_approver_id);
CREATE INDEX idx_expense_approvals_expense_id ON expense_approvals(expense_id);
CREATE INDEX idx_expense_approvals_approver_id ON expense_approvals(approver_id);
CREATE INDEX idx_conditional_approvals_expense_id ON conditional_approvals(expense_id);
CREATE INDEX idx_approval_rules_workflow_id ON approval_rules(workflow_id);
CREATE INDEX idx_conditional_approval_rules_workflow_id ON conditional_approval_rules(workflow_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_user_expense_history_user_id ON user_expense_history(user_id);

-- Insert sample data for a new company
-- This would typically be done when a company is created on first signup
INSERT INTO companies (name, default_currency, country_code) VALUES
('Sample Company', 'USD', 'US');

-- Sample expense categories
INSERT INTO expense_categories (company_id, name, code, description) VALUES
(1, 'Travel', 'TRAVEL', 'Business travel expenses'),
(1, 'Meals', 'MEALS', 'Business meals and entertainment'),
(1, 'Office Supplies', 'OFFICE', 'Office supplies and equipment'),
(1, 'Transportation', 'TRANS', 'Local transportation and parking'),
(1, 'Accommodation', 'HOTEL', 'Hotel and accommodation expenses'),
(1, 'Communication', 'COMM', 'Phone, internet, and communication expenses'),
(1, 'Training', 'TRAIN', 'Training and professional development'),
(1, 'Software', 'SOFT', 'Software licenses and subscriptions'),
(1, 'Other', 'OTHER', 'Other business expenses');

-- Sample approval workflow (Sequential: Manager → Finance → Director)
INSERT INTO approval_workflows (company_id, name, description, workflow_type) VALUES
(1, 'Standard Approval Flow', 'Manager → Finance → Director', 'sequential');

-- Sample approval rules for the workflow
INSERT INTO approval_rules (workflow_id, step_number, approver_role, min_amount, max_amount) VALUES
(1, 1, 'manager', 0, 1000.00),
(1, 2, 'finance', 1000.01, 5000.00),
(1, 3, 'director', 5000.01, 999999.99);

-- Sample conditional approval workflow (60% OR CFO approval)
INSERT INTO approval_workflows (company_id, name, description, workflow_type, percentage_threshold) VALUES
(1, 'Percentage Approval Flow', '60% of approvers OR CFO approval', 'hybrid', 60);

-- Sample conditional approval rules
INSERT INTO conditional_approval_rules (workflow_id, rule_name, rule_type, percentage_threshold, min_amount, max_amount) VALUES
(2, '60% Approval Rule', 'percentage', 60, 0, 999999.99),
(2, 'CFO Override Rule', 'specific_approver', NULL, 0, 999999.99);

-- Sample system settings
INSERT INTO system_settings (company_id, setting_key, setting_value, description) VALUES
(1, 'auto_approval_limit', '50.00', 'Amount below which expenses are auto-approved'),
(1, 'manager_approval_required', 'true', 'Whether manager approval is required'),
(1, 'email_notifications', 'true', 'Enable email notifications'),
(1, 'default_workflow_id', '1', 'Default approval workflow for new expenses');
