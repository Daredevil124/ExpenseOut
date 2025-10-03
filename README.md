# Expense Management System - Next.js + MongoDB

A comprehensive expense management system built with Next.js and MongoDB, based on the Odoo problem statement requirements.

## Features

- **Multi-tenant Architecture**: Company-based isolation
- **Role-based Access Control**: Admin, Manager, Employee roles
- **Multi-currency Support**: Expenses in different currencies
- **Flexible Approval Workflows**: Sequential and conditional approvals
- **Manager Hierarchy**: Proper manager-employee relationships
- **Real-time Notifications**: Approval requests and status updates
- **Audit Trail**: Complete tracking of all actions

## Database Schema

The system uses MongoDB with Mongoose ODM and includes the following models:

- **Company**: Multi-tenant company management
- **User**: Role-based user management with manager hierarchy
- **ExpenseCategory**: Expense categorization
- **Expense**: Core expense data with multi-currency support
- **ApprovalWorkflow**: Flexible approval process configuration
- **ApprovalRule**: Sequential approval steps
- **ConditionalApprovalRule**: Percentage-based and specific approver rules
- **ExpenseApproval**: Sequential approval tracking
- **ConditionalApproval**: Conditional approval tracking
- **Notification**: Real-time notifications
- **SystemSetting**: Company-specific configurations

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Variables

Create a `.env.local` file in the root directory:

```env
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/expense_management

# JWT Secret for authentication
JWT_SECRET=your-super-secret-jwt-key-here

# Next.js Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret-here

# Email Configuration (optional)
EMAIL_SERVER_HOST=smtp.gmail.com
EMAIL_SERVER_PORT=587
EMAIL_SERVER_USER=your-email@gmail.com
EMAIL_SERVER_PASSWORD=your-app-password
EMAIL_FROM=noreply@yourcompany.com

# Application Settings
NODE_ENV=development
```

### 3. Database Setup

Make sure MongoDB is running on your system. The application will automatically create the database and collections when you first run it.

### 4. Run the Application

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Project Structure

```
├── app/                    # Next.js app directory
│   ├── (auth)/            # Authentication pages
│   ├── dashboard/         # Dashboard pages
│   ├── api/              # API routes
│   └── globals.css       # Global styles
├── lib/                   # Utility libraries
│   └── db.js             # MongoDB connection
├── models/                # MongoDB models
│   ├── User.js           # User model
│   ├── Company.js        # Company model
│   ├── Expense.js        # Expense model
│   ├── ApprovalWorkflow.js # Approval workflow model
│   └── ...               # Other models
└── package.json          # Dependencies
```

## Key Features Implementation

### 1. User Registration & Company Creation

When a user signs up for the first time:
- A new company is automatically created
- An admin user is created for the company
- Default expense categories are set up
- Default approval workflows are configured

### 2. Role-based Access Control

- **Admin**: Can create users, manage roles, configure approval rules, view all expenses
- **Manager**: Can approve/reject expenses, view team expenses, escalate as per rules
- **Employee**: Can submit expenses, view their own expenses, check approval status

### 3. Expense Submission

Employees can submit expenses with:
- Amount (can be different from company's currency)
- Category, Description, Date
- Multi-currency support
- Manager approval requirement

### 4. Approval Workflows

The system supports two types of approval workflows:

#### Sequential Approval
- Step 1 → Manager
- Step 2 → Finance  
- Step 3 → Director

#### Conditional Approval
- 60% of approvers OR CFO approval
- Hybrid rules combining both approaches

### 5. Multi-currency Support

- Expenses can be submitted in any currency
- Company has a default currency
- Currency conversion handled at display time
- Exchange rates can be integrated

## API Endpoints

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Expenses
- `GET /api/expenses` - Get user's expenses
- `POST /api/expenses` - Submit new expense
- `PUT /api/expenses/[id]` - Update expense
- `DELETE /api/expenses/[id]` - Delete expense

### Approvals
- `GET /api/approvals/pending` - Get pending approvals
- `POST /api/approvals` - Approve/reject expense
- `GET /api/approvals/history` - Get approval history

### Users
- `GET /api/users` - Get users (admin only)
- `POST /api/users` - Create user (admin only)
- `PUT /api/users/[id]` - Update user (admin only)

## Database Models

### User Model
```javascript
{
  company_id: ObjectId,
  username: String,
  email: String,
  password_hash: String,
  first_name: String,
  last_name: String,
  employee_id: String,
  manager_id: ObjectId,
  role: String, // 'employee', 'manager', 'admin'
  is_manager_approver: Boolean,
  is_active: Boolean
}
```

### Expense Model
```javascript
{
  company_id: ObjectId,
  user_id: ObjectId,
  category_id: ObjectId,
  description: String,
  amount: Decimal128,
  currency: String,
  expense_date: Date,
  status: String, // 'pending', 'approved', 'rejected'
  current_approver_id: ObjectId,
  current_step: Number,
  workflow_id: ObjectId,
  is_manager_approval_required: Boolean
}
```

## Business Rules

1. **Company Creation**: Auto-created on first signup with admin user
2. **Manager Approval**: Required based on "IS MANAGER APPROVER" field
3. **Sequential Approval**: Expenses move through approval steps in order
4. **Conditional Approval**: 60% of approvers OR specific approver (e.g., CFO)
5. **Multi-currency**: Expenses can be in different currencies than company default
6. **Role Permissions**: Strict role-based access control
7. **Audit Trail**: All actions are logged for compliance

## Development

### Adding New Models

1. Create a new file in the `models/` directory
2. Define the schema with proper indexes
3. Add instance and static methods as needed
4. Export the model in `models/index.js`

### Adding New API Routes

1. Create a new file in `app/api/` directory
2. Use the database connection from `lib/db.js`
3. Import models from `models/index.js`
4. Implement proper error handling and validation

## Deployment

### MongoDB Atlas (Recommended)

1. Create a MongoDB Atlas account
2. Create a new cluster
3. Get the connection string
4. Update `MONGODB_URI` in your environment variables

### Self-hosted MongoDB

1. Install MongoDB on your server
2. Configure authentication and security
3. Update `MONGODB_URI` to point to your server

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.