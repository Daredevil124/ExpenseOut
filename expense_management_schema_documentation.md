# Expense Management System - Database Schema Documentation

## Overview

This document describes the comprehensive database schema for an expense management system designed to handle employee expense tracking, approval workflows, budget management, and financial reporting.

## Schema Design Principles

1. **Scalability**: Designed to handle large volumes of expense data with proper indexing
2. **Audit Trail**: Complete audit logging for compliance and tracking
3. **Flexibility**: Configurable approval workflows and business rules
4. **Security**: Role-based access control and data validation
5. **Performance**: Optimized queries with strategic indexing

## Core Entities

### 1. User Management

#### `users` Table
- **Purpose**: Stores employee information and authentication data
- **Key Features**:
  - Hierarchical structure with manager relationships
  - Role-based access (employee, manager, admin, finance)
  - Department association
  - Employee ID for external system integration

#### `departments` Table
- **Purpose**: Organizational structure and budget management
- **Key Features**:
  - Department-specific budget limits
  - Manager assignment
  - Department codes for reporting

### 2. Expense Management

#### `expense_categories` Table
- **Purpose**: Categorization of expense types
- **Key Features**:
  - Configurable receipt requirements
  - Approval requirements per category
  - Maximum amount limits
  - Active/inactive status

#### `expense_subcategories` Table
- **Purpose**: Detailed categorization within main categories
- **Key Features**:
  - Hierarchical relationship with categories
  - Granular expense tracking
  - Flexible subcategorization

#### `expenses` Table
- **Purpose**: Individual expense records
- **Key Features**:
  - Multi-currency support with exchange rates
  - Receipt attachment tracking
  - Project association
  - Approval workflow integration
  - Vendor information

#### `expense_reports` Table
- **Purpose**: Grouped expense submissions
- **Key Features**:
  - Batch processing of expenses
  - Status tracking (draft, submitted, approved, rejected, paid)
  - Approval workflow integration
  - Payment tracking

### 3. Approval Workflow

#### `approval_workflows` Table
- **Purpose**: Configurable approval processes
- **Key Features**:
  - Multiple workflow support
  - Department and category-specific rules
  - Amount-based approval levels

#### `approval_rules` Table
- **Purpose**: Business rules for approval routing
- **Key Features**:
  - Department-based routing
  - Category-specific rules
  - Amount thresholds
  - Multi-level approvals

#### `expense_approvals` Table
- **Purpose**: Individual approval records
- **Key Features**:
  - Approval level tracking
  - Comments and feedback
  - Status management

### 4. Budget Management

#### `budgets` Table
- **Purpose**: Budget allocation and tracking
- **Key Features**:
  - Department, project, and category budgets
  - Multiple time periods (monthly, quarterly, annual)
  - Automatic remaining amount calculation
  - Budget vs. actual spending tracking

### 5. Supporting Entities

#### `projects` Table
- **Purpose**: Project-based expense tracking
- **Key Features**:
  - Project budget management
  - Client information
  - Project lifecycle tracking

#### `company_cards` Table
- **Purpose**: Corporate card management
- **Key Features**:
  - Card assignment to users/departments
  - Credit limit tracking
  - Card status management

#### `receipt_attachments` Table
- **Purpose**: Receipt file management
- **Key Features**:
  - File metadata storage
  - Upload tracking
  - File type validation

### 6. System Features

#### `audit_logs` Table
- **Purpose**: Complete audit trail
- **Key Features**:
  - All data changes tracked
  - JSON storage for old/new values
  - User and IP tracking
  - Compliance support

#### `notifications` Table
- **Purpose**: User notifications
- **Key Features**:
  - Real-time notifications
  - Read/unread status
  - Related entity linking

#### `system_settings` Table
- **Purpose**: Configurable system parameters
- **Key Features**:
  - Business rule configuration
  - System behavior control
  - Easy maintenance

## Key Relationships

### 1. User Hierarchy
```
users (manager_id) → users (id)
users (department_id) → departments (id)
departments (manager_id) → users (id)
```

### 2. Expense Flow
```
expenses (user_id) → users (id)
expenses (report_id) → expense_reports (id)
expenses (category_id) → expense_categories (id)
expenses (subcategory_id) → expense_subcategories (id)
expenses (project_id) → projects (id)
```

### 3. Approval Chain
```
expense_approvals (expense_id) → expenses (id)
expense_approvals (approver_id) → users (id)
approval_rules (workflow_id) → approval_workflows (id)
approval_rules (approver_id) → users (id)
```

## Business Rules Implemented

### 1. Expense Validation
- Receipt requirements based on category and amount
- Maximum amounts per category
- Currency conversion with exchange rates
- Project association validation

### 2. Approval Workflow
- Multi-level approval based on amount and category
- Department-specific approval routing
- Manager hierarchy approval
- Automatic approval for small amounts

### 3. Budget Management
- Department and project budget tracking
- Real-time budget vs. actual spending
- Budget alerts and notifications
- Multi-period budget support

### 4. Compliance and Audit
- Complete audit trail for all changes
- Receipt attachment requirements
- Data retention policies
- User activity tracking

## Performance Optimizations

### 1. Indexing Strategy
- Primary key indexes on all tables
- Foreign key indexes for joins
- Composite indexes for common queries
- Status-based indexes for filtering

### 2. Query Optimization
- Computed columns for calculated fields
- Proper data types for efficient storage
- Normalized structure to reduce redundancy

## Security Considerations

### 1. Data Protection
- Password hashing for user authentication
- Role-based access control
- Audit logging for sensitive operations
- Data encryption for sensitive fields

### 2. Compliance
- Complete audit trail
- Data retention policies
- User consent tracking
- GDPR compliance features

## Scalability Features

### 1. Partitioning Strategy
- Date-based partitioning for large tables
- Department-based partitioning for multi-tenant scenarios
- Archive strategy for historical data

### 2. Performance Monitoring
- Query performance tracking
- Index usage monitoring
- Resource utilization metrics

## Integration Points

### 1. External Systems
- HR system integration via employee_id
- Accounting system integration
- Payment gateway integration
- Document management system integration

### 2. APIs
- RESTful API endpoints
- Webhook support for real-time updates
- Bulk data import/export
- Third-party service integration

## Maintenance and Operations

### 1. Data Maintenance
- Regular data archiving
- Index maintenance
- Statistics updates
- Backup and recovery procedures

### 2. Monitoring
- Database performance monitoring
- Error tracking and alerting
- User activity monitoring
- System health checks

## Future Enhancements

### 1. Advanced Features
- Machine learning for expense categorization
- Fraud detection algorithms
- Advanced reporting and analytics
- Mobile app integration

### 2. Scalability Improvements
- Read replicas for reporting
- Caching strategies
- Microservices architecture
- Cloud-native deployment

This schema provides a solid foundation for a comprehensive expense management system that can scale with business needs while maintaining data integrity and compliance requirements.
