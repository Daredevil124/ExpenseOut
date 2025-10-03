# Next.js Expense Management System - Implementation Guide

## Overview

This guide outlines how to implement the Odoo-style expense management system using Next.js, based on the problem statement requirements.

## Database Schema Summary

The system is built around these core entities:

### 1. **Companies** (Multi-tenant)
- Auto-created on first signup
- Default currency setting
- Country-specific configurations

### 2. **Users** (Role-based)
- **Admin**: Create company, manage users, set roles, configure approval rules, view all expenses, override approvals
- **Manager**: Approve/reject expenses, view team expenses, escalate as per rules
- **Employee**: Submit expenses, view their own expenses, check approval status

### 3. **Expenses** (Core Business Logic)
- Amount (can be different from company's currency)
- Category, Description, Date
- Multi-currency support
- Manager approval requirement (IS MANAGER APPROVER field)

### 4. **Approval Workflows** (Sequential & Conditional)
- **Sequential**: Step 1 → Manager, Step 2 → Finance, Step 3 → Director
- **Conditional**: 60% of approvers OR CFO approval
- **Hybrid**: Combination of both flows

## Next.js Implementation Structure

```
app/
├── (auth)/
│   ├── login/
│   │   └── page.js
│   ├── signup/
│   │   └── page.js
│   └── layout.js
├── dashboard/
│   ├── admin/
│   │   ├── users/
│   │   ├── approval-rules/
│   │   └── settings/
│   ├── manager/
│   │   ├── approvals/
│   │   └── team-expenses/
│   ├── employee/
│   │   ├── submit-expense/
│   │   └── my-expenses/
│   └── layout.js
├── api/
│   ├── auth/
│   ├── expenses/
│   ├── approvals/
│   └── users/
└── globals.css
```

## Key Features Implementation

### 1. **Authentication & User Management**

```javascript
// app/api/auth/signup/route.js
export async function POST(request) {
  const { email, password, firstName, lastName, companyName, countryCode } = await request.json();
  
  // Create company and admin user
  const company = await createCompany({
    name: companyName,
    country_code: countryCode,
    default_currency: getCurrencyByCountry(countryCode)
  });
  
  const adminUser = await createUser({
    company_id: company.id,
    email,
    password: await hashPassword(password),
    first_name: firstName,
    last_name: lastName,
    role: 'admin',
    is_manager_approver: true
  });
  
  return NextResponse.json({ company, user: adminUser });
}
```

### 2. **Expense Submission (Employee Role)**

```javascript
// app/api/expenses/route.js
export async function POST(request) {
  const { amount, currency, category_id, description, expense_date } = await request.json();
  const user = await getCurrentUser(request);
  
  // Check if manager approval is required
  const category = await getExpenseCategory(category_id);
  const requiresManagerApproval = category.requires_manager_approval;
  
  const expense = await createExpense({
    company_id: user.company_id,
    user_id: user.id,
    category_id,
    description,
    amount,
    currency,
    expense_date,
    is_manager_approval_required: requiresManagerApproval,
    status: 'pending'
  });
  
  // Assign to appropriate workflow
  const workflow = await getApprovalWorkflow(user.company_id, amount);
  await assignExpenseToWorkflow(expense.id, workflow.id);
  
  return NextResponse.json(expense);
}
```

### 3. **Approval Workflow (Manager/Admin Role)**

```javascript
// app/api/approvals/route.js
export async function POST(request) {
  const { expense_id, action, comments } = await request.json();
  const approver = await getCurrentUser(request);
  
  const expense = await getExpense(expense_id);
  
  if (action === 'approve') {
    // Handle sequential approval
    if (expense.workflow_type === 'sequential') {
      await handleSequentialApproval(expense, approver, comments);
    }
    // Handle conditional approval
    else if (expense.workflow_type === 'percentage') {
      await handleConditionalApproval(expense, approver, comments);
    }
  } else if (action === 'reject') {
    await rejectExpense(expense_id, approver.id, comments);
  }
  
  return NextResponse.json({ success: true });
}

async function handleSequentialApproval(expense, approver, comments) {
  const currentStep = expense.current_step;
  const workflow = await getApprovalWorkflow(expense.workflow_id);
  
  // Record approval
  await createExpenseApproval({
    expense_id: expense.id,
    approver_id: approver.id,
    step_number: currentStep,
    status: 'approved',
    comments
  });
  
  // Check if this was the final step
  const nextStep = currentStep + 1;
  const nextRule = await getApprovalRule(workflow.id, nextStep);
  
  if (!nextRule) {
    // Final approval
    await finalizeExpenseApproval(expense.id, approver.id);
  } else {
    // Move to next approver
    const nextApprover = await getNextApprover(expense, nextRule);
    await updateExpenseApprover(expense.id, nextApprover.id, nextStep);
  }
}
```

### 4. **Conditional Approval Logic**

```javascript
async function handleConditionalApproval(expense, approver, comments) {
  const workflow = await getApprovalWorkflow(expense.workflow_id);
  
  // Record conditional approval
  await createConditionalApproval({
    expense_id: expense.id,
    approver_id: approver.id,
    rule_id: workflow.rule_id,
    status: 'approved',
    comments
  });
  
  // Check if approval threshold is met
  const approvals = await getConditionalApprovals(expense.id);
  const approvalCount = approvals.filter(a => a.status === 'approved').length;
  const totalApprovers = await getTotalApprovers(expense);
  const percentage = (approvalCount / totalApprovers) * 100;
  
  // Check for specific approver override (e.g., CFO)
  const hasCFOApproval = approvals.some(a => 
    a.status === 'approved' && a.approver.role === 'cfo'
  );
  
  if (percentage >= workflow.percentage_threshold || hasCFOApproval) {
    await finalizeExpenseApproval(expense.id, approver.id);
  }
}
```

## Database Models (Prisma)

```prisma
// prisma/schema.prisma
model Company {
  id               Int      @id @default(autoincrement())
  name             String
  default_currency String   @default("USD")
  country_code     String?
  is_active        Boolean  @default(true)
  created_at       DateTime @default(now())
  updated_at       DateTime @updatedAt
  
  users            User[]
  expense_categories ExpenseCategory[]
  approval_workflows ApprovalWorkflow[]
  expenses         Expense[]
  system_settings  SystemSetting[]
}

model User {
  id                    Int      @id @default(autoincrement())
  company_id            Int
  username              String   @unique
  email                 String   @unique
  password_hash         String
  first_name            String
  last_name             String
  employee_id           String?
  manager_id            Int?
  role                  String   @default("employee")
  is_manager_approver   Boolean  @default(false)
  is_active             Boolean  @default(true)
  created_at            DateTime @default(now())
  updated_at            DateTime @updatedAt
  
  company               Company  @relation(fields: [company_id], references: [id])
  manager               User?    @relation("UserManager", fields: [manager_id], references: [id])
  employees             User[]   @relation("UserManager")
  expenses              Expense[]
  expense_approvals     ExpenseApproval[]
  conditional_approvals ConditionalApproval[]
  notifications         Notification[]
}

model Expense {
  id                        Int      @id @default(autoincrement())
  company_id                Int
  user_id                   Int
  category_id               Int
  description               String
  amount                    Decimal
  currency                  String
  expense_date              DateTime
  status                    String   @default("pending")
  current_approver_id       Int?
  current_step              Int      @default(1)
  workflow_id               Int?
  is_manager_approval_required Boolean @default(true)
  manager_approved          Boolean  @default(false)
  manager_approved_at       DateTime?
  manager_comments          String?
  final_approved_by         Int?
  final_approved_at         DateTime?
  rejected_by               Int?
  rejected_at               DateTime?
  rejection_reason          String?
  created_at                DateTime @default(now())
  updated_at                DateTime @updatedAt
  
  company                   Company  @relation(fields: [company_id], references: [id])
  user                      User     @relation(fields: [user_id], references: [id])
  category                  ExpenseCategory @relation(fields: [category_id], references: [id])
  current_approver          User?    @relation("ExpenseCurrentApprover", fields: [current_approver_id], references: [id])
  workflow                  ApprovalWorkflow? @relation(fields: [workflow_id], references: [id])
  final_approver            User?    @relation("ExpenseFinalApprover", fields: [final_approved_by], references: [id])
  rejector                  User?    @relation("ExpenseRejector", fields: [rejected_by], references: [id])
  
  expense_approvals         ExpenseApproval[]
  conditional_approvals     ConditionalApproval[]
  notifications             Notification[]
  user_expense_history      UserExpenseHistory[]
}

model ApprovalWorkflow {
  id                  Int      @id @default(autoincrement())
  company_id          Int
  name                String
  description         String?
  workflow_type       String   @default("sequential")
  percentage_threshold Int?
  is_active           Boolean  @default(true)
  created_at          DateTime @default(now())
  
  company             Company  @relation(fields: [company_id], references: [id])
  expenses            Expense[]
  approval_rules      ApprovalRule[]
  conditional_rules   ConditionalApprovalRule[]
}

model ApprovalRule {
  id                  Int      @id @default(autoincrement())
  workflow_id         Int
  step_number         Int
  approver_role       String?
  specific_approver_id Int?
  min_amount          Decimal  @default(0)
  max_amount          Decimal?
  is_required         Boolean  @default(true)
  is_active           Boolean  @default(true)
  created_at          DateTime @default(now())
  
  workflow            ApprovalWorkflow @relation(fields: [workflow_id], references: [id])
  specific_approver   User?    @relation(fields: [specific_approver_id], references: [id])
}

model ConditionalApprovalRule {
  id                  Int      @id @default(autoincrement())
  workflow_id         Int
  rule_name           String
  rule_type           String
  percentage_threshold Int?
  specific_approver_id Int?
  min_amount          Decimal  @default(0)
  max_amount          Decimal?
  is_active           Boolean  @default(true)
  created_at          DateTime @default(now())
  
  workflow            ApprovalWorkflow @relation(fields: [workflow_id], references: [id])
  specific_approver   User?    @relation(fields: [specific_approver_id], references: [id])
  conditional_approvals ConditionalApproval[]
}

model ExpenseApproval {
  id            Int      @id @default(autoincrement())
  expense_id    Int
  approver_id   Int
  step_number   Int
  status        String
  comments      String?
  approved_at   DateTime?
  created_at    DateTime @default(now())
  
  expense       Expense  @relation(fields: [expense_id], references: [id])
  approver      User     @relation(fields: [approver_id], references: [id])
}

model ConditionalApproval {
  id            Int      @id @default(autoincrement())
  expense_id    Int
  approver_id   Int
  rule_id       Int
  status        String
  comments      String?
  approved_at   DateTime?
  created_at    DateTime @default(now())
  
  expense       Expense  @relation(fields: [expense_id], references: [id])
  approver      User     @relation(fields: [approver_id], references: [id])
  rule          ConditionalApprovalRule @relation(fields: [rule_id], references: [id])
}
```

## Frontend Components

### 1. **Expense Submission Form**

```jsx
// app/dashboard/employee/submit-expense/page.js
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function SubmitExpense() {
  const [formData, setFormData] = useState({
    amount: '',
    currency: 'USD',
    category_id: '',
    description: '',
    expense_date: new Date().toISOString().split('T')[0]
  });
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const response = await fetch('/api/expenses', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    });
    
    if (response.ok) {
      router.push('/dashboard/employee/my-expenses');
    }
  };
  
  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto">
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">Amount</label>
        <input
          type="number"
          step="0.01"
          value={formData.amount}
          onChange={(e) => setFormData({...formData, amount: e.target.value})}
          className="w-full p-2 border rounded"
          required
        />
      </div>
      
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">Currency</label>
        <select
          value={formData.currency}
          onChange={(e) => setFormData({...formData, currency: e.target.value})}
          className="w-full p-2 border rounded"
        >
          <option value="USD">USD</option>
          <option value="EUR">EUR</option>
          <option value="GBP">GBP</option>
        </select>
      </div>
      
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">Category</label>
        <select
          value={formData.category_id}
          onChange={(e) => setFormData({...formData, category_id: e.target.value})}
          className="w-full p-2 border rounded"
          required
        >
          <option value="">Select Category</option>
          {/* Categories will be loaded from API */}
        </select>
      </div>
      
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">Description</label>
        <textarea
          value={formData.description}
          onChange={(e) => setFormData({...formData, description: e.target.value})}
          className="w-full p-2 border rounded"
          rows="3"
          required
        />
      </div>
      
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">Date</label>
        <input
          type="date"
          value={formData.expense_date}
          onChange={(e) => setFormData({...formData, expense_date: e.target.value})}
          className="w-full p-2 border rounded"
          required
        />
      </div>
      
      <button
        type="submit"
        className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700"
      >
        Submit Expense
      </button>
    </form>
  );
}
```

### 2. **Manager Approval Dashboard**

```jsx
// app/dashboard/manager/approvals/page.js
'use client';

import { useState, useEffect } from 'react';

export default function ManagerApprovals() {
  const [expenses, setExpenses] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchPendingApprovals();
  }, []);
  
  const fetchPendingApprovals = async () => {
    const response = await fetch('/api/approvals/pending');
    const data = await response.json();
    setExpenses(data);
    setLoading(false);
  };
  
  const handleApproval = async (expenseId, action, comments = '') => {
    const response = await fetch('/api/approvals', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        expense_id: expenseId,
        action,
        comments
      })
    });
    
    if (response.ok) {
      fetchPendingApprovals(); // Refresh the list
    }
  };
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <div className="max-w-6xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Pending Approvals</h1>
      
      <div className="grid gap-4">
        {expenses.map((expense) => (
          <div key={expense.id} className="border rounded-lg p-4">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="font-semibold">{expense.description}</h3>
                <p className="text-gray-600">
                  {expense.amount} {expense.currency} • {expense.category.name}
                </p>
                <p className="text-sm text-gray-500">
                  Submitted by {expense.user.first_name} {expense.user.last_name}
                </p>
                <p className="text-sm text-gray-500">
                  Date: {new Date(expense.expense_date).toLocaleDateString()}
                </p>
              </div>
              
              <div className="flex gap-2">
                <button
                  onClick={() => handleApproval(expense.id, 'approve')}
                  className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
                >
                  Approve
                </button>
                <button
                  onClick={() => {
                    const comments = prompt('Rejection reason:');
                    if (comments) handleApproval(expense.id, 'reject', comments);
                  }}
                  className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
                >
                  Reject
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Key Implementation Notes

1. **Multi-currency Support**: All amounts are stored with their original currency, with conversion handled at display time
2. **Role-based Access**: Middleware checks user roles before allowing access to specific routes
3. **Approval Workflow**: Flexible system supporting both sequential and conditional approvals
4. **Real-time Updates**: WebSocket or Server-Sent Events for real-time approval notifications
5. **Audit Trail**: All actions are logged for compliance and tracking

This implementation provides a complete foundation for the Odoo-style expense management system as specified in the problem statement.
